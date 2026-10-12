#!/usr/bin/env python3
"""Render Supermarket_Sales_FA2_Report.pdf from Supermarket_Sales_FA2_Report.docx.

Parses the generated DOCX (paragraphs, tables, inline figures, page breaks)
and renders an A4 print-ready PDF with the sample's page size, margins and
typography, using ReportLab. Because the PDF is built from the DOCX itself,
figure-for-figure and text-for-text correspondence holds by construction.

Usage (isolated venv with reportlab):
    /tmp/opencode/venv/bin/python report/build_pdf.py   (run from project root)
"""
import os
import re
import zipfile
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                TableStyle, Image, PageBreak)
from reportlab.lib import colors

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCX = os.path.join(ROOT, "report", "Supermarket_Sales_FA2_Report.docx")
PDF = os.path.join(ROOT, "report", "Supermarket_Sales_FA2_Report.pdf")

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
R = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
WP = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
A = "http://schemas.openxmlformats.org/drawingml/2006/main"

Q = lambda ns, tag: f"{{{ns}}}{tag}"

LEFT_IN, RIGHT_IN, TOP_IN, BOTTOM_IN = 1276 / 1440, 424 / 1440, 1.0, 1.0
PAGE_W, PAGE_H = A4
USABLE = PAGE_W - LEFT_IN * inch - RIGHT_IN * inch
FIG_W = 6.30 * inch


def font_name(rpr):
    fonts = rpr.find(Q(W, "rFonts"))
    fam = "Times"
    if fonts is not None:
        fam = fonts.get(Q(W, "ascii")) or "Times"
    bold = rpr.find(Q(W, "b")) is not None
    italic = rpr.find(Q(W, "i")) is not None
    if "Consolas" in fam or "Courier" in fam:
        return "Courier-Bold" if bold else "Courier"
    if bold and italic:
        return "Times-BoldItalic"
    if bold:
        return "Times-Bold"
    if italic:
        return "Times-Italic"
    return "Times-Roman"


def run_markup(run):
    rpr = run.find(Q(W, "rPr"))
    size = 12.0
    color = None
    fname = "Times-Roman"
    if rpr is not None:
        sz = rpr.find(Q(W, "sz"))
        if sz is not None:
            size = float(sz.get(Q(W, "val"))) / 2.0
        col = rpr.find(Q(W, "color"))
        if col is not None and col.get(Q(W, "val")) not in (None, "auto"):
            color = "#" + col.get(Q(W, "val"))
        fname = font_name(rpr)
    text = "".join(t.text or "" for t in run.findall(Q(W, "t")))
    text = escape(text)
    open_tags = f'<font name="{fname}" size="{size}">'
    if color:
        open_tags += f'<font color="{color}">'
    close_tags = "</font>" * (2 if color else 1)
    return open_tags + text + close_tags, fname, size


def main():
    z = zipfile.ZipFile(DOCX)
    doc = ET.fromstring(z.read("word/document.xml"))
    rels = ET.fromstring(z.read("word/_rels/document.xml.rels"))
    target = {r.get("Id"): r.get("Target") for r in rels}
    body = doc.find(Q(W, "body"))

    story = []
    code_style = ParagraphStyle("code", fontName="Courier", fontSize=11,
                                leading=13, leftIndent=18, spaceBefore=0,
                                spaceAfter=0, backColor=HexColor("#F2F2F2"),
                                borderPadding=(2, 2, 6))
    base_style = ParagraphStyle("base", fontName="Times-Roman", fontSize=14,
                                leading=17)

    for block in body:
        tag = block.tag
        if tag == Q(W, "p"):
            ppr = block.find(Q(W, "pPr"))
            jc = None
            if ppr is not None:
                j = ppr.find(Q(W, "jc"))
                if j is not None:
                    jc = j.get(Q(W, "val"))
            align = {"center": TA_CENTER, "both": TA_JUSTIFY, "left": TA_LEFT}.get(jc, TA_JUSTIFY)
            parts, fnames, sizes = [], set(), []
            has_page_break = False
            has_drawing = False
            drawing_rid, drawing_ext = None, None
            for run in block.findall(Q(W, "r")):
                if run.find(Q(W, "br")) is not None:
                    br = run.find(Q(W, "br"))
                    if br.get(Q(W, "type")) == "page":
                        has_page_break = True
                    else:
                        parts.append("<br/>")
                    continue
                dr = run.find(Q(W, "drawing"))
                if dr is not None:
                    has_drawing = True
                    inline = dr.find(Q(WP, "inline"))
                    ext = inline.find(Q(WP, "extent"))
                    cx, cy = float(ext.get("cx")), float(ext.get("cy"))
                    blip = inline.find(f".//{{{A}}}blip")
                    drawing_rid = blip.get(f"{{{R}}}embed")
                    drawing_ext = (cx, cy)
                    continue
                mk, fn, sz = run_markup(run)
                parts.append(mk)
                fnames.add(fn)
                sizes.append(sz)
            if has_page_break and not "".join(parts).strip():
                story.append(PageBreak())
                continue
            if has_drawing:
                media = "word/" + target[drawing_rid]
                tmp = os.path.join("/tmp", "opencode", os.path.basename(media))
                with open(tmp, "wb") as f:
                    f.write(z.read(media))
                cx, cy = drawing_ext
                h = FIG_W * cy / cx
                story.append(Image(tmp, width=FIG_W, height=h, hAlign="CENTER"))
                story.append(Spacer(1, 4))
                continue
            text = "".join(parts)
            if not text.strip():
                story.append(Spacer(1, 6))
                continue
            if fnames == {"Courier"} or fnames == {"Courier-Bold"}:
                story.append(Paragraph(text, code_style))
            else:
                lead = max(sizes) * 1.18 if sizes else 17
                st = ParagraphStyle(f"p{len(story)}", parent=base_style,
                                    alignment=align, leading=lead)
                story.append(Paragraph(text, st))
        elif tag == Q(W, "tbl"):
            grid = [int(c.get(Q(W, "w"))) / 20.0
                    for c in block.find(Q(W, "tblGrid"))]
            scale = min(1.0, USABLE / sum(grid))
            widths = [w * scale for w in grid]
            data = []
            for tr in block.findall(Q(W, "tr")):
                row = []
                for tc in tr.findall(Q(W, "tc")):
                    texts = []
                    for p in tc.findall(Q(W, "p")):
                        t = "".join(t2.text or "" for r in p.findall(Q(W, "r"))
                                    for t2 in r.findall(Q(W, "t")))
                        texts.append(escape(t.strip()))
                    row.append(Paragraph("<br/>".join(texts),
                                         ParagraphStyle(f"c{len(story)}{len(data)}{len(row)}",
                                                        fontName="Times-Roman",
                                                        fontSize=10, leading=12,
                                                        alignment=TA_CENTER)))
                data.append(row)
            t = Table(data, colWidths=widths, hAlign="CENTER", repeatRows=1)
            t.setStyle(TableStyle([
                ("GRID", (0, 0), (-1, -1), 0.5, colors.black),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
            ]))
            story.append(Spacer(1, 6))
            story.append(t)
            story.append(Spacer(1, 6))
        elif tag == Q(W, "sectPr"):
            continue

    tmpl = SimpleDocTemplate(PDF, pagesize=A4,
                             leftMargin=LEFT_IN * inch, rightMargin=RIGHT_IN * inch,
                             topMargin=TOP_IN * inch, bottomMargin=BOTTOM_IN * inch,
                             title="Supermarket Sales FA-2 Report",
                             subject="Statistical Data Analysis using R")
    tmpl.build(story)
    print(f"Wrote {PDF} ({os.path.getsize(PDF)} bytes)")


if __name__ == "__main__":
    main()
