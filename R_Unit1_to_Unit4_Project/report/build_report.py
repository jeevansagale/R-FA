#!/usr/bin/env python3
"""Build Supermarket_Sales_FA2_Report.docx from verified project outputs.

Reads the executed R results (outputs/reports/*.csv, *.txt) and the report
figures (report/figures/fig1..fig7.png), and writes a .docx that follows the
structure and formatting of the instructor sample
("Sample Report for FA2 Activity.docx"): A4, sample margins, Times New Roman,
centered cover page, red Flow list, blue problem-statement headings, result
table + R code + figure + conclusion per problem statement.

Pure standard library (zipfile/struct/csv/re) so it runs anywhere.
Usage: python3 report/build_report.py   (run from the project root)
"""
import csv
import os
import re
import struct
import sys
import zipfile
from xml.sax.saxutils import escape

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REP = os.path.join(ROOT, "outputs", "reports")
FIG = os.path.join(ROOT, "report", "figures")
OUT = os.path.join(ROOT, "report", "Supermarket_Sales_FA2_Report.docx")

NS = ('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
      'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
      'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
      'xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"')

EMU_PER_INCH = 914400
FIG_W_IN = 6.30


def money(x):
    return f"{float(x):,.2f}"


def mean2(x):
    return f"{float(x):,.2f}"


def stat3(x):
    return f"{float(x):.3f}"


def pval(x):
    x = float(x)
    if x < 0.001:
        return f"{x:.2e}"
    return f"{x:.3f}"


def read_csv(path):
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def read_txt(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def png_size(path):
    with open(path, "rb") as f:
        data = f.read(32)
    return struct.unpack(">II", data[16:24])


def runs_xml(runs):
    out = []
    for text, kw in runs:
        rpr = []
        if kw.get("font"):
            rpr.append(f'<w:rFonts w:ascii="{kw["font"]}" w:hAnsi="{kw["font"]}" w:cs="{kw["font"]}"/>')
        else:
            rpr.append('<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>')
        if kw.get("size"):
            rpr.append(f'<w:sz w:val="{kw["size"] * 2}"/><w:szCs w:val="{kw["size"] * 2}"/>')
        if kw.get("bold"):
            rpr.append("<w:b/><w:bCs/>")
        if kw.get("italic"):
            rpr.append("<w:i/><w:iCs/>")
        if kw.get("color"):
            rpr.append(f'<w:color w:val="{kw["color"]}" w:themeColor="auto"/>')
        out.append(f'<w:r><w:rPr>{"".join(rpr)}</w:rPr><w:t xml:space="preserve">{escape(text)}</w:t></w:r>')
    return "".join(out)


def para(runs, jc="both", style=None, page_break=False, spacing_after=None):
    ppr = []
    if style:
        ppr.append(f'<w:pStyle w:val="{style}"/>')
    if jc:
        ppr.append(f'<w:jc w:val="{jc}"/>')
    if spacing_after is not None:
        ppr.append(f'<w:spacing w:after="{spacing_after}"/>')
    if page_break:
        body = f'<w:r><w:br w:type="page"/></w:r>{runs_xml(runs)}' if runs else '<w:r><w:br w:type="page"/></w:r>'
    else:
        body = runs_xml(runs)
    return f'<w:p><w:pPr>{"".join(ppr)}</w:pPr>{body}</w:p>'


T = lambda t, **kw: (t, kw)  # text run helper


def simple(text, size=14, bold=False, color=None, jc="both", italic=False):
    return para([T(text, size=size, bold=bold, color=color, italic=italic)], jc=jc)


CELL_BORDER = ('<w:tcBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
               '<w:left w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
               '<w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/>'
               '<w:right w:val="single" w:sz="4" w:space="0" w:color="auto"/></w:tcBorders>')


def table(headers, rows, widths, header_bold=True):
    grid = "".join(f'<w:gridCol w:w="{w}"/>' for w in widths)
    trs = []
    for ri, row in enumerate([headers] + rows):
        tcs = []
        for ci, (cell, w) in enumerate(zip(row, widths)):
            is_header = ri == 0
            cell_runs = runs_xml([T(cell, size=12, bold=(is_header and header_bold))])
            align = "center" if (is_header or ci == 0) else "center"
            tcs.append(
                f'<w:tc><w:tcPr><w:tcW w:w="{w}" w:type="dxa"/>{CELL_BORDER}'
                f'<w:vAlign w:val="center"/></w:tcPr>'
                f'<w:p><w:pPr><w:jc w:val="{align}"/></w:pPr>{cell_runs}</w:p></w:tc>')
        trpr = '<w:trPr><w:jc w:val="center"/></w:trPr>' if ri == 0 else ''
        trs.append(f"<w:tr>{trpr}{''.join(tcs)}</w:tr>")
    return (f'<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/>'
            f'<w:jc w:val="center"/><w:tblLook w:val="04A0"/></w:tblPr>'
            f'<w:tblGrid>{grid}</w:tblGrid>{"".join(trs)}</w:tbl>')


FIG_COUNTER = [0]
FIG_FILES = []


def inline_image(fig_file, width_in):
    """Centered image with no caption (cover logo)."""
    FIG_COUNTER[0] += 1
    idx = FIG_COUNTER[0]
    FIG_FILES.append(fig_file)
    rid = f"rIdFig{idx}"
    pw, ph = png_size(os.path.join(FIG, fig_file))
    h_in = width_in * ph / pw
    cx, cy = int(width_in * EMU_PER_INCH), int(h_in * EMU_PER_INCH)
    drawing = (
        f'<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">'
        f'<wp:extent cx="{cx}" cy="{cy}"/><wp:docPr id="{idx}" name="logo"/>'
        f'<wp:cNvGraphicFramePr><a:graphicFrameLocks locked="1"/></wp:cNvGraphicFramePr>'
        f'<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        f'<pic:pic><pic:nvPicPr><pic:cNvPr id="{idx}" name="logo"/><pic:cNvPicPr/></pic:nvPicPr>'
        f'<pic:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
        f'<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm>'
        f'<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
        f'</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>')
    return f'<w:p><w:pPr><w:jc w:val="center"/></w:pPr>{drawing}</w:p>'


def figure(fig_file, caption):
    FIG_COUNTER[0] += 1
    idx = FIG_COUNTER[0]
    FIG_FILES.append(fig_file)
    rid = f"rIdFig{idx}"
    pw, ph = png_size(os.path.join(FIG, fig_file))
    h_in = FIG_W_IN * ph / pw
    cx, cy = int(FIG_W_IN * EMU_PER_INCH), int(h_in * EMU_PER_INCH)
    drawing = (
        f'<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">'
        f'<wp:extent cx="{cx}" cy="{cy}"/><wp:docPr id="{idx}" name="{escape(caption)}"/>'
        f'<wp:cNvGraphicFramePr><a:graphicFrameLocks locked="1"/></wp:cNvGraphicFramePr>'
        f'<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        f'<pic:pic><pic:nvPicPr><pic:cNvPr id="{idx}" name="{escape(caption)}"/><pic:cNvPicPr/></pic:nvPicPr>'
        f'<pic:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
        f'<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm>'
        f'<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
        f'</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>')
    pic_para = f'<w:p><w:pPr><w:jc w:val="center"/></w:pPr>{drawing}</w:p>'
    cap_para = para([T(caption, size=12, italic=True)], jc="center")
    return pic_para, cap_para, rid


def code_block(lines):
    out = []
    for line in lines:
        out.append(para([T(line, size=11, font="Consolas")], jc="left", spacing_after=0))
    return "".join(out)


# ---------------------------------------------------------------- data load
ps1 = read_csv(os.path.join(REP, "ps1_product_line_revenue.csv"))
ps2 = read_csv(os.path.join(REP, "ps2_branch_comparison.csv"))
ps3 = read_csv(os.path.join(REP, "ps3_customer_type.csv"))
ps4 = read_csv(os.path.join(REP, "ps4_payment_method.csv"))
ps6 = read_csv(os.path.join(REP, "ps6_rating_summary.csv"))[0]
ps7m = read_csv(os.path.join(REP, "ps7_monthly_revenue.csv"))
ps7d = read_csv(os.path.join(REP, "ps7_weekday_revenue.csv"))
tests = {r["Problem_statement"]: r for r in read_csv(os.path.join(REP, "ps_inferential_tests.csv"))}
unit3 = read_csv(os.path.join(REP, "unit3_simple_regression_metrics.csv"))[0]
unit4m = read_csv(os.path.join(REP, "unit4_model_metrics.csv"))[0]
unit4f = read_csv(os.path.join(REP, "unit4_model_form_comparison.csv"))
ps5txt = read_txt(os.path.join(REP, "ps5_quantity_total_correlation.txt"))
ps6txt = read_txt(os.path.join(REP, "ps6_rating_total_correlation.txt"))

t_ps1, t_ps2 = tests["PS1: product line"], tests["PS2: branch"]
t_ps3, t_ps4 = tests["PS3: customer type"], tests["PS4: payment method"]
t_ps5, t_ps6 = tests["PS5: quantity vs total"], tests["PS6: rating vs total"]

ps1 = sorted(ps1, key=lambda r: -float(r["Revenue"]))
rev_total = sum(float(r["Revenue"]) for r in ps1)

# ---------------------------------------------------------------- document
B = []  # body blocks

# ---- cover page
B.append(simple("PIMPRI CHINCHWAD EDUCATION TRUST'S", size=14, jc="center"))
B.append(simple("", size=14, jc="center"))
B.append(simple("PIMPRI CHINCHWAD COLLEGE OF ENGINEERING", size=18, jc="center"))
B.append(inline_image("pccoe_logo.png", 1.40))
B.append(simple("Department of AS&H", size=24, bold=True, jc="center"))
B.append(simple("Report of FA-2 activity", size=20, bold=True, jc="center"))
B.append(simple("", size=12))
B.append(simple("Subject: Statistical Data Analysis using R", size=12, bold=True))
B.append(simple("Academic Year 2026-27", size=12, bold=True))
B.append(simple("Semester I", size=12, bold=True))
B.append(simple("Submitted by             Name of the student:                       PRN number                   Branch       Sign", size=12, bold=True))
B.append(simple("                           1.  Aditya Kuwar                           125B1B097                    [Branch]      ______", size=12))
B.append(simple("                           2.  Jeevan Sagale                          125B1B080                    [Branch]      ______", size=12))
B.append(simple("                           3.  Vedant Hire                            125B1B099                    [Branch]      ______", size=12))
B.append(simple("                           4.  Tanay Daware                           125B1B098                    [Branch]      ______", size=12))
B.append(simple("", size=12))
B.append(simple("Submitted to: Dr. Sujata Bhamre", size=12, bold=True))
B.append(simple("Date: [DD/MM/YYYY]", size=12, bold=True))
B.append(simple("Sign:", size=12, bold=True))
B.append(para([], page_break=True))

# ---- title / data / variables
B.append(simple("Project Title: Descriptive analysis of Supermarket Sales data using R", size=16, bold=True, jc="center"))
B.append(simple("Data used: supermarket_sales.csv - 1,000 supermarket transactions recorded from 1 January 2019 to 30 March 2019 across three branches (A/Yangon, B/Mandalay, C/Naypyitaw) and six product lines.", size=12))
B.append(simple("Details of the data: Data contains 1000 observations and 17 variables as follows", size=12))
variables = [
    "Invoice ID - invoice/computer-generated sales slip number (identifier, unique for every row)",
    "Branch - branch of the supercenter (A, B, C)",
    "City - city of the branch (Yangon, Mandalay, Naypyitaw; one-to-one with Branch)",
    "Customer type - Member or Normal",
    "Gender - Female or Male",
    "Product line - one of six product categories (Health and beauty, Electronic accessories, Home and lifestyle, Sports and travel, Food and beverages, Fashion accessories)",
    "Unit price - price of one unit of the product",
    "Quantity - number of units purchased on the invoice",
    "Tax 5% - 5 percent tax on the cost of goods sold (equals gross income in every row)",
    "Total - invoice total, equal to 1.05 x Quantity x Unit price in every row",
    "Date - date of purchase (text in the CSV, parsed as a date for grouping)",
    "Time - time of purchase (text)",
    "Payment - payment method (Cash, Credit card, Ewallet)",
    "cogs - cost of goods sold, equal to Quantity x Unit price in every row",
    "gross margin percentage - constant at 4.761905 for every row (not a variable that explains differences)",
    "gross income - equal to Tax 5% in every row (5 percent of cogs)",
    "Rating - customer rating of the purchase experience (4.0 to 10.0)",
]
for i, v in enumerate(variables, 1):
    B.append(para([T(f"{i}. {v}", size=12)], jc="both"))
B.append(simple("Six of the variables are categorical grouping fields (Branch, City, Customer type, Gender, Product line, Payment) and eight are numeric (Unit price, Quantity, Tax 5%, Total, cogs, gross margin percentage, gross income, Rating); Date and Time are stored as text and Invoice ID is an identifier. The financial columns Total, cogs, Tax 5% and gross income are linked by the invoice formula, so regressions that use them together reproduce accounting arithmetic rather than discovering independent drivers.", size=12))
B.append(simple("", size=12))

RED = "FF0000"
B.append(simple("Flow:", size=14, bold=True, color=RED))
for item in ["Problem Statement", "Statistical Analysis", "Data Visualization",
             "Coding  (Also add R code for every Problem Statement)",
             "Correlation, Regression Analysis.", "Conclusion:"]:
    B.append(simple(item, size=14, bold=True, color=RED))
B.append(simple("", size=12))

BLUE = "000000"  # problem-statement headings in black (no blue fonts)


def ps_heading(text):
    return simple(text, size=14, bold=True, color=BLUE)


def conclusion(text):
    return para([T("Conclusion: ", size=14, bold=True), T(text, size=14)], jc="both")


def code_label():
    return simple("Code:", size=12, bold=True)


# ---- PS1
B.append(ps_heading("Problem statement 1: Which product lines generate the greatest total revenue?"))
B.append(simple("The data are grouped by product line and, for each line, the number of transactions, total revenue, mean and median invoice totals, mean quantity, mean gross income and mean rating are calculated with group_by() and summarise(). A one-way ANOVA tests whether mean invoice totals differ across the six product lines.", size=14))
B.append(table(
    ["Product line", "Transactions", "Revenue", "Mean invoice total", "Median invoice total", "Mean rating"],
    [[r["Product line"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"]),
      mean2(r["Median_Total"]), mean2(r["Mean_Rating"])] for r in ps1],
    [2600, 1300, 1500, 1650, 1700, 1210]))
B.append(simple(f"It shows that Food and beverages records the highest revenue ({money(ps1[0]['Revenue'])} from {ps1[0]['Transactions']} transactions) and Health and beauty the lowest ({money(ps1[-1]['Revenue'])} from {ps1[-1]['Transactions']} transactions). Revenue combines how many invoices a line has with how large they are, so the ranking alone does not measure profit or satisfaction. It can be visualised by a bar chart as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "ps1 <- sales_clean %>% group_by(`Product line`) %>%",
    "  summarise(Transactions = n(), Revenue = sum(Total),",
    "            Mean_Total = mean(Total), Mean_Rating = mean(Rating),",
    "            .groups = \"drop\") %>%",
    "  arrange(desc(Revenue))",
    "ps1_anova <- aov(Total ~ `Product line`, data = sales_clean)",
    "summary(ps1_anova)",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig1_revenue_by_product_line.png", "Figure 1. Total revenue by product line (sum of invoice Total).")
B.append(pic); B.append(cap)
B.append(conclusion(f"Food and beverages has the highest recorded revenue ({money(ps1[0]['Revenue'])}), followed by Sports and travel ({money(ps1[1]['Revenue'])}); Health and beauty is lowest ({money(ps1[-1]['Revenue'])}). The one-way ANOVA gives F = {stat3(t_ps1['Statistic'])}, p = {pval(t_ps1['P_value'])}, so there is no statistically significant evidence that mean invoice totals differ across product lines at the 5% level."))

# ---- PS2
ps2s = sorted(ps2, key=lambda r: -float(r["Revenue"]))
B.append(ps_heading("Problem statement 2: How do the branches compare in total revenue and average invoice total?"))
B.append(simple("Branches A, B and C are compared with grouped totals, transaction counts and mean invoice totals. A one-way ANOVA on Total by Branch tests whether the branch means differ. (City matches Branch one-to-one: A-Yangon, B-Mandalay, C-Naypyitaw.)", size=14))
B.append(table(
    ["Branch", "City", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Branch"], r["City"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps2s],
    [1100, 1900, 1600, 1900, 2060]))
B.append(simple(f"Branch C (Naypyitaw) has the highest total revenue ({money(ps2s[0]['Revenue'])}) and the highest mean invoice total ({mean2(ps2s[0]['Mean_Total'])}); branches A and B are nearly tied at about {money(float(ps2s[1]['Revenue']))} and {money(float(ps2s[2]['Revenue']))}. It can be visualised by a bar chart as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "ps2 <- sales_clean %>% group_by(Branch, City) %>%",
    "  summarise(Transactions = n(), Revenue = sum(Total),",
    "            Mean_Total = mean(Total), .groups = \"drop\")",
    "ps2_anova <- aov(Total ~ Branch, data = sales_clean)",
    "summary(ps2_anova)",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig2_revenue_by_branch.png", "Figure 2. Total revenue by branch (C = Naypyitaw, A = Yangon, B = Mandalay).")
B.append(pic); B.append(cap)
B.append(conclusion(f"Branch C has the highest aggregate revenue, but the ANOVA (F = {stat3(t_ps2['Statistic'])}, p = {pval(t_ps2['P_value'])}) does not find a statistically significant difference in mean invoice totals across branches at the 5% level. Revenue totals also reflect the number and mix of transactions, not branch efficiency."))

# ---- PS3
B.append(ps_heading("Problem statement 3: Do Member and Normal customers have different average invoice totals?"))
B.append(simple("Average and median invoice totals are compared for the two customer types with group summaries and a Welch two-sample t-test (unequal variances not assumed). Filtered boxplots for Members and Normal customers are drawn in one panel with grid viewports, following the instructor sample-script pattern.", size=14))
B.append(table(
    ["Customer type", "Transactions", "Revenue", "Mean invoice total", "Median invoice total", "SD"],
    [[r["Customer type"], r["N"], money(r["Revenue"]), mean2(r["Mean_Total"]),
      mean2(r["Median_Total"]), mean2(r["SD_Total"])] for r in sorted(ps3, key=lambda r: r["Customer type"], reverse=True)],
    [1900, 1500, 1600, 1800, 1800, 1250]))
m3 = {r["Customer type"]: r for r in ps3}
B.append(simple(f"Members average {mean2(m3['Member']['Mean_Total'])} per transaction and Normal customers {mean2(m3['Normal']['Mean_Total'])}; medians are {mean2(m3['Member']['Median_Total'])} and {mean2(m3['Normal']['Median_Total'])}. The distributions overlap heavily, as the boxplots show.", size=14))
B.append(code_label())
B.append(code_block([
    "ps3 <- sales_clean %>% group_by(`Customer type`) %>%",
    "  summarise(N = n(), Mean_Total = mean(Total),",
    "            Median_Total = median(Total), .groups = \"drop\")",
    "ps3_test <- t.test(Total ~ `Customer type`, data = sales_clean)",
    "ps3_test",
    "plot_member <- filter(sales_clean, `Customer type` == \"Member\") %>%",
    "  ggplot(aes(y = Total)) + geom_boxplot()",
    "plot_normal <- filter(sales_clean, `Customer type` == \"Normal\") %>%",
    "  ggplot(aes(y = Total)) + geom_boxplot()",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig3_customer_type_boxplot.png", "Figure 3. Invoice total by customer type (box = interquartile range, line = median).")
B.append(pic); B.append(cap)
B.append(conclusion(f"The Welch t-test gives t = {stat3(t_ps3['Statistic'])}, df = {float(t_ps3['DF']):.1f}, p = {pval(t_ps3['P_value'])} (95% CI for the difference: -20.86 to 40.19), so this sample provides no statistically significant evidence of a mean difference at the 5% level. This does not prove the groups are identical."))

# ---- PS4
ps4s = sorted(ps4, key=lambda r: -int(r["N"]))
B.append(ps_heading("Problem statement 4: Which payment methods are most used, and do mean invoice totals differ?"))
B.append(simple("Transaction counts, revenue and mean invoice totals are compared for Cash, Credit card and Ewallet with grouped summaries and a one-way ANOVA on Total by Payment.", size=14))
B.append(table(
    ["Payment method", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Payment"], r["N"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps4s],
    [2200, 1700, 1900, 2200]))
B.append(simple(f"Ewallet records {ps4s[0]['N']} transactions and Cash {ps4s[1]['N']}, almost equally frequent; Credit card is used least ({ps4s[2]['N']}). Mean invoice totals are close ({mean2(ps4s[1]['Mean_Total'])}, {mean2(ps4s[2]['Mean_Total'])} and {mean2(ps4s[0]['Mean_Total'])} respectively). It can be visualised by a bar chart as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "ps4 <- sales_clean %>% group_by(Payment) %>%",
    "  summarise(N = n(), Revenue = sum(Total),",
    "            Mean_Total = mean(Total), .groups = \"drop\")",
    "ps4_anova <- aov(Total ~ Payment, data = sales_clean)",
    "summary(ps4_anova)",
    "ggplot(sales_clean, aes(x = Payment, fill = Payment)) + geom_bar()",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig4_payment_methods.png", "Figure 4. Number of transactions by payment method.")
B.append(pic); B.append(cap)
B.append(conclusion(f"Ewallet and Cash dominate usage in this sample. The ANOVA (F = {stat3(t_ps4['Statistic'])}, p = {pval(t_ps4['P_value'])}) gives no evidence that average invoice totals differ by payment method at the 5% level."))

# ---- PS5
B.append(ps_heading("Problem statement 5: How strongly is quantity associated with invoice total?"))
B.append(simple("The linear association between quantity purchased and invoice total is measured with a scatterplot and Pearson correlation (cor.test), with unit price kept alongside quantity in a linear model as a syllabus exercise. Note that Total = 1.05 x Quantity x Unit price in every row, so these models reproduce the invoice formula rather than discovering a new driver.", size=14))
B.append(table(
    ["Measure", "Value"],
    [["Pearson correlation r (Quantity, Total)", stat3(t_ps5["Statistic"])],
     ["Sample size n", "1000"],
     ["95% confidence interval", "0.673 to 0.735"],
     ["p-value", pval(t_ps5["P_value"])],
     ["Unit-price correlation r (Unit price, Total)", "0.634"],
     ["Regression Total ~ Quantity + Unit price: adjusted R-squared", "0.890"]],
    [5000, 3210]))
B.append(code_label())
B.append(code_block([
    "ps5_cor <- cor.test(sales_clean$Quantity, sales_clean$Total,",
    "                    method = \"pearson\")",
    "ps5_cor",
    "ps5_model <- lm(Total ~ Quantity + `Unit price`, data = sales_clean)",
    "summary(ps5_model)",
    "ggplot(sales_clean, aes(x = Quantity, y = Total)) +",
    "  geom_point() + geom_smooth(method = \"lm\")",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig5_quantity_vs_total.png", "Figure 5. Quantity purchased versus invoice total, with fitted line (Pearson r = 0.706, n = 1000).")
B.append(pic); B.append(cap)
B.append(conclusion("Quantity and invoice total have a strong positive Pearson correlation (r = 0.706, 95% CI 0.673 to 0.735, p < 0.001). Invoices with more items tend to be larger, but unit prices vary widely and Total is computed from quantity and unit price, so this is an expected association and not causal evidence."))

# ---- PS6
B.append(ps_heading("Problem statement 6: What does the customer-rating distribution show, and is rating related to invoice total?"))
B.append(simple("Customer ratings are described with mean, median, standard deviation, range and a histogram, and their linear association with invoice total is tested with Pearson correlation.", size=14))
B.append(table(
    ["Rating summary", "Value"],
    [["Transactions rated (n)", "1000"],
     ["Mean rating", mean2(ps6["Mean_Rating"])],
     ["Median rating", mean2(ps6["Median_Rating"])],
     ["Standard deviation", stat3(ps6["SD_Rating"])],
     ["Minimum - Maximum", f"{mean2(ps6['Min_Rating'])} - {mean2(ps6['Max_Rating'])}"],
     ["Correlation r (Rating, Total)", stat3(t_ps6["Statistic"])],
     ["p-value", pval(t_ps6["P_value"])]],
    [5000, 3210]))
B.append(code_label())
B.append(code_block([
    "mean(sales_clean$Rating); median(sales_clean$Rating)",
    "sd(sales_clean$Rating); min(sales_clean$Rating); max(sales_clean$Rating)",
    "ps6_cor <- cor.test(sales_clean$Rating, sales_clean$Total)",
    "ps6_cor",
    "ggplot(sales_clean, aes(x = Rating)) + geom_histogram(binwidth = 0.5)",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig6_rating_distribution.png", "Figure 6. Distribution of customer ratings (dashed line = mean).")
B.append(pic); B.append(cap)
B.append(conclusion(f"Ratings span 4.0 to 10.0 with mean {mean2(ps6['Mean_Rating'])} and median 7.0. Their correlation with invoice total is very weak (r = {stat3(t_ps6['Statistic'])}, p = {pval(t_ps6['P_value'])}), so higher-value invoices are not demonstrably associated with higher ratings in this sample."))

# ---- PS7
B.append(ps_heading("Problem statement 7: How does revenue vary across months and weekdays?"))
B.append(simple("Date text is converted with as.Date(), Month and Weekday are derived, and revenue, transaction counts and means are summarised per month and per weekday. The data cover only 1 January to 30 March 2019, so the results describe this period and do not establish a long-term trend.", size=14))
B.append(table(
    ["Month", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Month"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps7m],
    [2200, 1900, 2000, 2110]))
B.append(table(
    ["Weekday", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Weekday"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps7d],
    [2200, 1900, 2000, 2110]))
B.append(simple(f"January has the highest revenue ({money(ps7m[0]['Revenue'])}; {ps7m[0]['Transactions']} transactions), February the lowest ({money(ps7m[1]['Revenue'])}; {ps7m[1]['Transactions']} transactions) and March recovers ({money(ps7m[2]['Revenue'])}). Among weekdays, Saturday records the highest revenue ({money(ps7d[0]['Revenue'])}) and the highest mean invoice total ({mean2(ps7d[0]['Mean_Total'])}). It can be visualised as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "sales_clean$Month <- format(sales_clean$Date, \"%Y-%m\")",
    "sales_clean$Weekday <- weekdays(sales_clean$Date)",
    "ps7_month <- sales_clean %>% group_by(Month) %>%",
    "  summarise(N = n(), Revenue = sum(Total),",
    "            Mean_Total = mean(Total), .groups = \"drop\")",
    "ggplot(ps7_month, aes(x = Month, y = Revenue, group = 1)) +",
    "  geom_col() + geom_line() + geom_point()",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap, _ = figure("fig7_monthly_revenue.png", "Figure 7. Revenue by month over the supplied three-month period.")
B.append(pic); B.append(cap)
B.append(conclusion("January leads on both revenue and transaction count, February dips, and March recovers. Saturday is the strongest weekday descriptively. With only three observed months, these are sample descriptions, not seasonal findings, and no causal explanation can be drawn from the CSV alone."))

# ---- correlation & regression
B.append(ps_heading("Correlation, Regression Analysis."))
B.append(simple("Following the Flow of the activity, the correlation and regression exercises are summarised here with their actual fitted values. Unit III fits gross income on cogs (simple linear regression); Unit IV fits invoice total on unit price, quantity, branch and payment (multiple linear regression) with residual diagnostics, confidence intervals and predictions.", size=14))
B.append(table(
    ["Model", "Key fitted result"],
    [["Simple regression: gross income ~ cogs",
      f"Intercept {float(unit3['Intercept']):.2e}, slope {float(unit3['Slope']):.4f}, R-squared {float(unit3['R_Squared']):.4f} (n = {unit3['Observations']})"],
     ["Unit III warning",
      "summary.lm() reports an essentially perfect fit: gross income is 5% of cogs by construction"],
     ["Multiple regression: Total ~ Unit price + Quantity + Branch + Payment",
      f"Adjusted R-squared {float(unit4m['Adjusted_R_Squared']):.3f}, residual SE {float(unit4m['Residual_Standard_Error']):.2f} (n = {unit4m['Observations']})"],
     ["Significant coefficients",
      "Unit price (t = 59.66) and Quantity (t = 66.54); Branch and Payment terms are not significant (p = 0.104 to 0.927)"],
     ["Form check",
      "Additive R-squared 0.891 vs interaction (Unit price x Quantity) R-squared 1.000: the invoice formula is multiplicative, so the additive model is descriptive, not causal"]],
    [3800, 4410]))
B.append(code_label())
B.append(code_block([
    "simple_model <- lm(`gross income` ~ cogs, data = regression_data)",
    "summary(simple_model)   # slope 0.05, R-squared = 1: the 5% invoice rule",
    "multiple_model <- lm(Total ~ `Unit price` + Quantity + Branch + Payment,",
    "                     data = model_data)",
    "summary(multiple_model); confint(multiple_model)",
    "interaction_model <- lm(Total ~ `Unit price` * Quantity, data = model_data)",
    "summary(interaction_model)   # R-squared = 1: the multiplicative formula",
]))
B.append(conclusion("The simple regression restates the 5% invoice rule and the interaction model restates the full invoice formula; both are syllabus exercises in fitting and diagnosing models, not business discoveries. The additive multiple regression is a valid descriptive model (adjusted R-squared 0.890) whose Branch and Payment effects are not significant."))

# ---- overall conclusion
B.append(ps_heading("Conclusion:"))
B.append(simple(f"Total recorded revenue across the 1,000 supplied invoices is {money(rev_total)} (mean invoice total {mean2(rev_total / 1000)}). Food and beverages has the highest product-line revenue, Branch C (Naypyitaw) the highest branch revenue, and quantity is positively associated with invoice total (r = 0.706). Customer ratings centre near 7 and show almost no linear association with invoice total (r = -0.036, p = 0.250). Mean invoice-total differences by branch, product line, payment method and customer type are all statistically non-significant at the 5% level. The project demonstrates Unit I data handling, Unit II wrangling and visualisation, Unit III correlation and simple regression, and Unit IV multiple regression with diagnostics, all computed from the supplied CSV with reproducible R scripts.", size=14))
B.append(simple("Limitations: the data are observational transactions from three branches over three months; inventory, costs, promotions and customer demographics are absent; Total, cogs, Tax 5% and gross income are algebraically linked and gross margin percentage is constant, so models using them are mechanical; Branch and City duplicate each other; and non-significant tests do not prove equality. Future work could collect a longer period, add cost and promotion fields, and model product mix with the multiplicative invoice structure made explicit.", size=14))
B.append(simple("", size=12))

# ---- appendix
B.append(ps_heading("Appendix A. R project execution."))
B.append(simple("Open R_Unit1_to_Unit4_Project.Rproj in RStudio and run main.R from the project root (or run Rscript main.R). requirements.R checks dplyr and ggplot2 (required) and tidyr (optional, one toy demo). The dataset loads from data/supermarket_sales.csv, falling back to the documented Windows practical path if needed. Scripts execute in order: unit1, course_concept_demos, unit2, unit3, unit4, data_analysis, problem_statements, report_figures, verify_results. Tables land in outputs/reports/, plots in outputs/plots/, the seven report figures in report/figures/. verify_results.R recomputes all 20 headline numbers from the raw CSV and stops on any mismatch (all matched in the submitted run, R 4.6.1).", size=12))
B.append(simple("Key files: main.R, requirements.R, scripts/unit1.R-unit4.R, scripts/problem_statements.R, scripts/data_analysis.R, scripts/report_figures.R, scripts/verify_results.R, functions/helper_functions.R, data/supermarket_sales.csv, PLAN.md, README.md, UNIT_MAPPING.md, oral_exam/viva_questions_and_functions.md.", size=12))
B.append(ps_heading("References."))
B.append(simple("1. Supplied dataset: supermarket_sales.csv (1,000 rows, 17 columns; source publisher not included with the file). 2. Supplied course materials: SDAUR.zip (Unit I command script, dplyr, descriptive statistics, plotting practicals, linear and multiple regression notes, missing-value, join, type-change and tidyr materials) and the instructor sample script sample project_FA2.R. 3. R Core Team. R: A Language and Environment for Statistical Computing. https://www.r-project.org/.", size=12))
B.append(simple("Team: Aditya Kuwar (125B1B097), Jeevan Sagale (125B1B080), Vedant Hire (125B1B099), Tanay Daware (125B1B098). [Still to complete before submission: branch, submission date, signatures.]", size=12, bold=True))

# ---------------------------------------------------------------- assemble
sect = ('<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1440" w:right="424" w:bottom="1440" w:left="1276" '
        'w:header="708" w:footer="708" w:gutter="0"/>'
        '<w:cols w:space="708"/><w:docGrid w:linePitch="360"/></w:sectPr>')
document = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document {NS}><w:body>{"".join(B)}{sect}</w:body></w:document>'

styles = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-IN"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="160" w:line="259" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="160" w:line="259" w:lineRule="auto"/></w:pPr><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120"/></w:pPr><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:b/><w:sz w:val="32"/><w:color w:val="1F4E79"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Code"><w:name w:val="Code"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="360"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
</w:styles>'''

numbering = f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:numbering {NS}><w:abstractNum w:abstractNumId="0"><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/><w:lvlText w:val="%1."/><w:lvlJc w:val="left"/><w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr></w:lvl></w:abstractNum><w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num></w:numbering>'''

content_types = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
                 '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
                 '<Default Extension="xml" ContentType="application/xml"/>'
                 '<Default Extension="png" ContentType="image/png"/>'
                 '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
                 '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
                 '<Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>'
                 '<Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>'
                 '<Override PartName="/word/fontTable.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"/>'
                 '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
                 '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
                 '</Types>')

rels = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
        '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
        '</Relationships>')

doc_rels = ['<Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>',
            '<Relationship Id="rIdNum" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>',
            '<Relationship Id="rIdSet" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>',
            '<Relationship Id="rIdFont" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable" Target="fontTable.xml"/>']
rid_of = {}
for i, fig in enumerate(FIG_FILES, 1):
    rid = f"rIdFig{i}"
    rid_of[fig] = rid
    doc_rels.append(f'<Relationship Id="{rid}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/{fig}"/>')
doc_rels_xml = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
                + "".join(doc_rels) + '</Relationships>')

settings = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
            '<w:zoom w:percent="100"/><w:defaultTabStop w:val="708"/>'
            '<w:compat><w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="15"/></w:compat></w:settings>')
fonttable = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:fonts xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
             '<w:font w:name="Times New Roman"/><w:font w:name="Consolas"/></w:fonts>')
core = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>Supermarket Sales FA-2 Report</dc:title><dc:subject>Statistical Data Analysis using R</dc:subject><dc:creator>FA-2 R Project</dc:creator></cp:coreProperties>')
app = ('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"><Application>FA-2 report builder</Application></Properties>')

with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", content_types)
    z.writestr("_rels/.rels", rels)
    z.writestr("word/document.xml", document)
    z.writestr("word/_rels/document.xml.rels", doc_rels_xml)
    z.writestr("word/styles.xml", styles)
    z.writestr("word/numbering.xml", numbering)
    z.writestr("word/settings.xml", settings)
    z.writestr("word/fontTable.xml", fonttable)
    z.writestr("docProps/core.xml", core)
    z.writestr("docProps/app.xml", app)
    for fig in FIG_FILES:
        z.writestr(f"word/media/{fig}", open(os.path.join(FIG, fig), "rb").read())

print(f"Wrote {OUT} ({os.path.getsize(OUT)} bytes, {len(FIG_FILES)} figures)")
