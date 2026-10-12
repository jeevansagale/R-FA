#!/usr/bin/env python3
"""Build Supermarket_Sales_FA2_Report.docx from verified project outputs.

Reads the executed R results (outputs/reports/*.csv, *.txt) and the report
figures (report/figures/fig1..fig5.png + pccoe_logo.png), and writes a .docx
that follows the structure of the instructor sample
("Sample Report for FA2 Activity.docx"): A4, sample margins, Times New Roman,
centered cover page with logo and team, red Flow list, black problem-statement
headings, result table + R code + figure + conclusion per problem statement.

Pure standard library (zipfile/struct/csv/re) so it runs anywhere.
Usage: python3 report/build_report.py   (run from the project root)
"""
import csv
import os
import re
import struct
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


T = lambda t, **kw: (t, kw)


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
            tcs.append(
                f'<w:tc><w:tcPr><w:tcW w:w="{w}" w:type="dxa"/>{CELL_BORDER}'
                f'<w:vAlign w:val="center"/></w:tcPr>'
                f'<w:p><w:pPr><w:jc w:val="center"/></w:pPr>{cell_runs}</w:p></w:tc>')
        trpr = '<w:trPr><w:jc w:val="center"/></w:trPr>' if ri == 0 else ''
        trs.append(f"<w:tr>{trpr}{''.join(tcs)}</w:tr>")
    return (f'<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/>'
            f'<w:jc w:val="center"/><w:tblLook w:val="04A0"/></w:tblPr>'
            f'<w:tblGrid>{grid}</w:tblGrid>{"".join(trs)}</w:tbl>')


FIG_COUNTER = [0]
FIG_FILES = []


def inline_image(fig_file, width_in):
    FIG_COUNTER[0] += 1
    idx = FIG_COUNTER[0]
    FIG_FILES.append(fig_file)
    rid = f"rIdFig{idx}"
    pw, ph = png_size(os.path.join(FIG, fig_file))
    h_in = width_in * ph / pw
    cx, cy = int(width_in * EMU_PER_INCH), int(h_in * EMU_PER_INCH)
    drawing = (
        f'<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">'
        f'<wp:extent cx="{cx}" cy="{cy}"/><wp:docPr id="{idx}" name="img{idx}"/>'
        f'<wp:cNvGraphicFramePr><a:graphicFrameLocks locked="1"/></wp:cNvGraphicFramePr>'
        f'<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
        f'<pic:pic><pic:nvPicPr><pic:cNvPr id="{idx}" name="img{idx}"/><pic:cNvPicPr/></pic:nvPicPr>'
        f'<pic:blipFill><a:blip r:embed="{rid}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>'
        f'<pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="{cx}" cy="{cy}"/></a:xfrm>'
        f'<a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>'
        f'</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>')
    return f'<w:p><w:pPr><w:jc w:val="center"/></w:pPr>{drawing}</w:p>', rid


def figure(fig_file, caption, width_in=FIG_W_IN):
    pic_para, _ = inline_image(fig_file, width_in)
    cap_para = para([T(caption, size=12, italic=True)], jc="center")
    return pic_para, cap_para


def code_block(lines):
    out = []
    for line in lines:
        out.append(para([T(line, size=11, font="Consolas")], jc="left", spacing_after=0))
    return "".join(out)


# ---------------------------------------------------------------- data load
ps1 = read_csv(os.path.join(REP, "ps1_product_line_performance.csv"))
ps2r = read_csv(os.path.join(REP, "ps2_branch_revenue.csv"))
ps2c = read_csv(os.path.join(REP, "ps2_branch_customer_counts.csv"))
ps3g = read_csv(os.path.join(REP, "ps3_payment_by_gender.csv"))
ps3c = read_csv(os.path.join(REP, "ps3_payment_by_customertype.csv"))
ps4h = read_csv(os.path.join(REP, "ps4_hourly.csv"))
ps4p = read_csv(os.path.join(REP, "ps4_part_of_day.csv"))
ps4d = read_csv(os.path.join(REP, "ps4_weekday.csv"))
ps5p = read_csv(os.path.join(REP, "ps5_profitability_by_product.csv"))
tests = {r["Problem_statement"]: r for r in read_csv(os.path.join(REP, "ps_inferential_tests.csv"))}
unit3 = read_csv(os.path.join(REP, "unit3_simple_regression_metrics.csv"))[0]
unit4m = read_csv(os.path.join(REP, "unit4_model_metrics.csv"))[0]

t = tests
rev_total = sum(float(r["Revenue"]) for r in ps2r)

# ---------------------------------------------------------------- document
B = []

# ---- cover page
B.append(simple("PIMPRI CHINCHWAD EDUCATION TRUST'S", size=14, jc="center"))
B.append(simple("", size=14, jc="center"))
B.append(simple("PIMPRI CHINCHWAD COLLEGE OF ENGINEERING", size=18, jc="center"))
B.append(inline_image("pccoe_logo.png", 1.40)[0])
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
B.append(simple("Data used: supermarket_sales.csv - 1,000 supermarket transactions recorded from 1 January 2019 to 30 March 2019 across three branches (A/Yangon, B/Mandalay, C/Naypyitaw) and six product lines. Store opening hours are 10:00 to 20:00.", size=12))
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
    "Date - date of purchase (text in the CSV, parsed as a date; Weekday derived for PS4)",
    "Time - time of purchase as HH:MM text (Hour and part of day derived for PS4)",
    "Payment - payment method (Cash, Credit card, Ewallet)",
    "cogs - cost of goods sold, equal to Quantity x Unit price in every row",
    "gross margin percentage - constant at 4.761905 for every row (not a variable that explains differences)",
    "gross income - equal to Tax 5% in every row (5 percent of cogs)",
    "Rating - customer rating of the purchase experience (4.0 to 10.0)",
]
for i, v in enumerate(variables, 1):
    B.append(para([T(f"{i}. {v}", size=12)], jc="both"))
B.append(simple("Six variables are categorical grouping fields (Branch, City, Customer type, Gender, Product line, Payment) and eight are numeric; Date and Time are stored as text and Invoice ID is an identifier. The financial columns are linked by the invoice formula, so models using them together reproduce accounting arithmetic rather than discovering independent drivers.", size=12))
B.append(simple("", size=12))

RED = "FF0000"
B.append(simple("Flow:", size=14, bold=True, color=RED))
for item in ["Problem Statement", "Statistical Analysis", "Data Visualization",
             "Coding  (Also add R code for every Problem Statement)",
             "Correlation, Regression Analysis.", "Conclusion:"]:
    B.append(simple(item, size=14, bold=True, color=RED))
B.append(simple("", size=12))


def ps_heading(text):
    return simple(text, size=14, bold=True, color="000000")


def conclusion(text):
    return para([T("Conclusion: ", size=14, bold=True), T(text, size=14)], jc="both")


def code_label():
    return simple("Code:", size=12, bold=True)


# ---- PS1: Product Line Performance & Satisfaction
B.append(ps_heading("Problem statement 1: Product Line Performance & Satisfaction - How do average customer Rating scores and gross income vary across different Product line categories?"))
B.append(simple("Transactions are grouped by product line with group_by() and summarise(); for each line the mean and standard deviation of Rating and the mean and total gross income are computed. One-way ANOVA tests whether mean ratings and mean gross incomes differ across the six lines.", size=14))
B.append(table(
    ["Product line", "Transactions", "Mean rating", "SD rating", "Mean gross income", "Total gross income"],
    [[r["Product line"], r["Transactions"], mean2(r["Mean_Rating"]), mean2(r["SD_Rating"]),
      mean2(r["Mean_Gross_Income"]), money(r["Total_Gross_Income"])] for r in ps1],
    [2250, 1250, 1250, 1100, 1600, 1760]))
t1r, t1g = t["PS1: product line ratings"], t["PS1: product line gross income"]
B.append(simple(f"Food and beverages has the highest mean rating ({mean2(ps1[0]['Mean_Rating'])}) and Home and lifestyle the lowest ({mean2(ps1[-1]['Mean_Rating'])}); the spread is narrow (SD about 1.7 in every line). Total gross income is also highest for Food and beverages ({money(ps1[0]['Total_Gross_Income'])}) while mean gross income per invoice is highest for Home and lifestyle ({mean2('16.03033125')}). It can be visualised by bar charts as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "ps1 <- sales_clean %>% group_by(`Product line`) %>%",
    "  summarise(Transactions = n(), Mean_Rating = mean(Rating),",
    "            SD_Rating = sd(Rating),",
    "            Mean_Gross_Income = mean(`gross income`),",
    "            Total_Gross_Income = sum(`gross income`),",
    "            .groups = \"drop\")",
    "summary(aov(Rating ~ `Product line`, data = sales_clean))",
    "summary(aov(`gross income` ~ `Product line`, data = sales_clean))",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap = figure("fig1_product_line_performance.png", "Figure 1. Mean rating (top) and total gross income (bottom) by product line.")
B.append(pic); B.append(cap)
B.append(conclusion(f"Food and beverages leads on satisfaction ({mean2(ps1[0]['Mean_Rating'])}) and on total gross income ({money(ps1[0]['Total_Gross_Income'])}). The rating ANOVA (F = {stat3(t1r['Statistic'])}, p = {pval(t1r['P_value'])}) and the gross-income ANOVA (F = {stat3(t1g['Statistic'])}, p = {pval(t1g['P_value'])}) are both non-significant at 5%: the observed line differences are small relative to within-line variation."))

# ---- PS2: Geographical & Branch Sales Comparison
B.append(ps_heading("Problem statement 2: Geographical & Branch Sales Comparison - Is there a statistically significant difference in revenue (Total) and Customer type distribution among the three branches (Branch / City)?"))
B.append(simple("Revenue, transaction counts and mean invoice totals are compared per Branch/City with grouped summaries and a one-way ANOVA on Total. The Member/Normal mix per branch is tabulated and tested with a chi-square test of independence.", size=14))
ps2s = sorted(ps2r, key=lambda r: -float(r["Revenue"]))
B.append(table(
    ["Branch", "City", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Branch"], r["City"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps2s],
    [1100, 1900, 1600, 1900, 2060]))
mix = {}
for r in ps2c:
    mix.setdefault(r["Branch"], {})[r["Customer_Type"]] = r["Transactions"]
B.append(table(
    ["Branch", "Member transactions", "Normal transactions"],
    [[b, mix[b]["Member"], mix[b]["Normal"]] for b in ["A", "B", "C"]],
    [2200, 2600, 2600]))
t2a, t2c = t["PS2: branch revenue"], t["PS2: branch customer mix"]
B.append(simple(f"Branch C (Naypyitaw) records the highest revenue ({money(ps2s[0]['Revenue'])}) and mean invoice ({mean2(ps2s[0]['Mean_Total'])}); A and B are nearly tied near {money(float(ps2s[1]['Revenue']))}. The Member/Normal split is close to 50/50 in every branch. It can be visualised as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "ps2_rev <- sales_clean %>% group_by(Branch, City) %>%",
    "  summarise(Transactions = n(), Revenue = sum(Total),",
    "            Mean_Total = mean(Total), .groups = \"drop\")",
    "summary(aov(Total ~ Branch, data = sales_clean))",
    "table(sales_clean$Branch, sales_clean$`Customer type`)",
    "chisq.test(table(sales_clean$Branch, sales_clean$`Customer type`))",
    "ggplot(fig2_counts, aes(x = Branch, y = Transactions,",
    "       fill = `Customer type`)) + geom_col(position = \"dodge\")",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap = figure("fig2_branch_comparison.png", "Figure 2. Revenue (top) and Member/Normal mix (bottom) by branch.")
B.append(pic); B.append(cap)
B.append(conclusion(f"Branch C leads on revenue, but the ANOVA (F = {stat3(t2a['Statistic'])}, p = {pval(t2a['P_value'])}) shows no significant mean-invoice difference, and the chi-square test (X-squared = {stat3(t2c['Statistic'])}, df = 2, p = {pval(t2c['P_value'])}) shows the customer-type mix does not depend on branch. Geography affects totals only through volume, not through a different customer mix."))

# ---- PS3: Payment Method Demographics
B.append(ps_heading("Problem statement 3: Payment Method Demographics - Which Payment methods are preferred across different Gender and Customer type segments?"))
B.append(simple("Payment counts are cross-tabulated with Gender and with Customer type (table()), segment shares are computed, and two chi-square tests of independence check whether preference depends on the segment.", size=14))
B.append(table(
    ["Payment", "Female (n)", "Female share %", "Male (n)", "Male share %"],
    [["Cash", "178", "35.5", "166", "33.3"],
     ["Credit card", "163", "32.5", "148", "29.7"],
     ["Ewallet", "160", "31.9", "185", "37.1"]],
    [2000, 1400, 1600, 1400, 1600]))
B.append(table(
    ["Payment", "Member (n)", "Member share %", "Normal (n)", "Normal share %"],
    [["Cash", "168", "33.5", "176", "35.3"],
     ["Credit card", "172", "34.3", "139", "27.9"],
     ["Ewallet", "161", "32.1", "184", "36.9"]],
    [2000, 1400, 1600, 1400, 1600]))
t3g, t3c = t["PS3: payment by gender"], t["PS3: payment by customer type"]
B.append(simple("Females use Cash most (35.5%) while males prefer Ewallet (37.1%); Members split almost evenly with Credit card marginally first (34.3%), while Normal customers favour Ewallet (36.9%) and use Credit card least (27.9%). It can be visualised as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "table(sales_clean$Payment, sales_clean$Gender)",
    "table(sales_clean$Payment, sales_clean$`Customer type`)",
    "chisq.test(table(sales_clean$Payment, sales_clean$Gender))",
    "chisq.test(table(sales_clean$Payment, sales_clean$`Customer type`))",
    "ggplot(Data, aes(x = Payment, fill = Gender)) +",
    "  geom_bar(position = \"dodge\") + facet_wrap(~`Customer type`)",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap = figure("fig3_payment_demographics.png", "Figure 3. Payment method by gender, faceted by customer type (dodged bars).")
B.append(pic); B.append(cap)
B.append(conclusion(f"Descriptively, Cash leads among females and Ewallet among males and Normal customers, but neither chi-square test is significant at 5% (gender: X-squared = {stat3(t3g['Statistic'])}, p = {pval(t3g['P_value'])}; customer type: X-squared = {stat3(t3c['Statistic'])}, p = {pval(t3c['P_value'])}). Payment preference does not demonstrably depend on these segments in this sample."))

# ---- PS4: Peak Shopping Hours & Days
B.append(ps_heading("Problem statement 4: Peak Shopping Hours & Days - What time of day (Time) and day of the week (Date) experience the highest customer volume and order totals?"))
B.append(simple("Hour is extracted from Time text and Weekday from Date; transactions, revenue and mean totals are summarised per hour, per part of day and per weekday. Chi-square goodness-of-fit tests check whether volume is uniform across hours and weekdays.", size=14))
B.append(table(
    ["Hour", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Hour"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps4h],
    [1400, 1700, 1900, 2110]))
B.append(table(
    ["Part of day", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Part_of_day"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps4p],
    [2300, 1700, 1900, 2110]))
B.append(table(
    ["Weekday", "Transactions", "Revenue", "Mean invoice total"],
    [[r["Weekday"], r["Transactions"], money(r["Revenue"]), mean2(r["Mean_Total"])] for r in ps4d],
    [2000, 1700, 1900, 2110]))
t4h, t4d = t["PS4: hourly volume"], t["PS4: weekday volume"]
B.append(simple(f"Hour 19:00 is busiest ({ps4h[0]['Transactions']} transactions, {money(ps4h[0]['Revenue'])} revenue); the afternoon block (13-16) carries the most traffic overall ({ps4p[0]['Transactions']} transactions). Saturday is the strongest day ({ps4d[0]['Transactions']} transactions, {money(ps4d[0]['Revenue'])}), Monday the weakest ({ps4d[-1]['Transactions']}). It can be visualised as follows.", size=14))
B.append(code_label())
B.append(code_block([
    "sales_clean$Hour <- as.integer(substr(sales_clean$Time, 1, 2))",
    "sales_clean$Weekday <- weekdays(sales_clean$Date)",
    "ps4_hour <- sales_clean %>% group_by(Hour) %>%",
    "  summarise(Transactions = n(), Revenue = sum(Total),",
    "            Mean_Total = mean(Total), .groups = \"drop\")",
    "chisq.test(table(sales_clean$Hour))   # uniform hours?",
    "chisq.test(table(sales_clean$Weekday)) # uniform weekdays?",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap = figure("fig4_peak_hours_days.png", "Figure 4. Transactions by hour (top) and revenue by weekday (bottom).")
B.append(pic); B.append(cap)
B.append(conclusion(f"Evenings (especially 19:00) and Saturdays draw the most shoppers and money in this sample. The uniformity tests do not reject even spread at 5% (hours: X-squared = {stat3(t4h['Statistic'])}, p = {pval(t4h['P_value'])}; weekdays: X-squared = {stat3(t4d['Statistic'])}, p = {pval(t4d['P_value'])}), so the peaks are descriptive patterns, not proven systematic differences."))

# ---- PS5: Profitability & Pricing Elasticity
B.append(ps_heading("Problem statement 5: Profitability & Pricing Elasticity - How does product Unit price impact purchase Quantity and total gross income generated?"))
B.append(simple("Pearson correlation (cor.test) measures the linear links of Unit price with Quantity and with gross income; a scatterplot shows the price-quantity cloud; and product lines are ranked by total gross income with their mean prices and quantities. A simple regression line is fitted as a syllabus exercise with the invoice-formula caution.", size=14))
B.append(table(
    ["Product line", "Mean unit price", "Mean quantity", "Total gross income", "Total revenue"],
    [[r["Product line"], mean2(r["Mean_Unit_Price"]), mean2(r["Mean_Quantity"]),
      money(r["Total_Gross_Income"]), money(r["Total_Revenue"])] for r in ps5p],
    [2250, 1400, 1300, 1750, 1710]))
t5q, t5g = t["PS5: price vs quantity"], t["PS5: price vs gross income"]
B.append(table(
    ["Measure", "Value"],
    [["Pearson r (Unit price, Quantity)", stat3(t5q["Statistic"])],
     ["p-value", pval(t5q["P_value"])],
     ["Pearson r (Unit price, gross income)", stat3(t5g["Statistic"])],
     ["p-value", pval(t5g["P_value"])],
     ["Regression gross income ~ Unit price: adjusted R-squared", "0.401"]],
    [5000, 3210]))
B.append(simple(f"Unit price and quantity have essentially no linear relationship (r = {stat3(t5q['Statistic'])}, p = {pval(t5q['P_value'])}): expensive items are not bought in systematically smaller amounts here, so no pricing elasticity is visible. Gross income rises with unit price (r = {stat3(t5g['Statistic'])}), but gross income equals 5% of Quantity x Unit price by construction, so this is invoice arithmetic. Food and beverages generates the most total gross income ({money(ps5p[0]['Total_Gross_Income'])}).", size=14))
B.append(code_label())
B.append(code_block([
    "ps5_qty <- cor.test(sales_clean$`Unit price`, sales_clean$Quantity)",
    "ps5_qty   # r near 0: no linear price-quantity link",
    "ps5_gross <- cor.test(sales_clean$`Unit price`,",
    "                      sales_clean$`gross income`)",
    "ggplot(sales_clean, aes(x = `Unit price`, y = Quantity,",
    "       color = `Product line`)) + geom_point()",
    "lm(`gross income` ~ `Unit price`, data = sales_clean)",
]))
B.append(simple("Data Visualization:", size=14))
pic, cap = figure("fig5_price_vs_quantity.png", "Figure 5. Unit price versus quantity by product line (dashed = fitted line, r = 0.011).")
B.append(pic); B.append(cap)
B.append(conclusion("There is no demonstrable pricing elasticity in this sample: quantity does not fall as unit price rises. Profitability ranking follows revenue ranking because the margin rate is constant, with Food and beverages on top. Price can therefore not be used from these data to predict how much customers will buy."))

# ---- Correlation, Regression Analysis.
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
B.append(simple(f"Total recorded revenue across the 1,000 supplied invoices is {money(rev_total)}. Food and beverages earns the highest satisfaction ({mean2(ps1[0]['Mean_Rating'])}) and the most total gross income ({money(ps1[0]['Total_Gross_Income'])}), though line differences are not statistically significant. Branch C (Naypyitaw) leads revenue ({money(ps2s[0]['Revenue'])}) with the same ~50/50 Member/Normal mix as the other branches. Payment preference leans to Cash among females and Ewallet among males and Normal customers, without significant segment dependence. Evenings (19:00) and Saturdays are the busiest descriptively. Unit price shows no linear link to quantity purchased (r = 0.011), so no pricing elasticity is demonstrable. The project demonstrates Unit I data handling, Unit II wrangling and visualisation, Unit III correlation and simple regression, and Unit IV multiple regression with diagnostics, all computed from the supplied CSV with reproducible R scripts.", size=14))
B.append(simple("Limitations: the data are observational transactions from three branches over three months (hours 10:00-20:00); inventory, costs, promotions and customer demographics are absent; Total, cogs, Tax 5% and gross income are algebraically linked and gross margin percentage is constant, so models using them are mechanical; Branch and City duplicate each other; and non-significant tests do not prove equality. Future work could collect a longer period, add cost and promotion fields, and study price effects with real price variation over time.", size=14))
B.append(simple("", size=12))

# ---- appendix
B.append(ps_heading("Appendix A. R project execution."))
B.append(simple("Open R_Unit1_to_Unit4_Project.Rproj in RStudio and run main.R from the project root (or run Rscript main.R). requirements.R checks dplyr and ggplot2 (required) and tidyr (optional, one toy demo). The dataset loads from data/supermarket_sales.csv, falling back to the documented Windows practical path if needed. Scripts execute in order: unit1, course_concept_demos, unit2, unit3, unit4, problem_statements (PS1-PS5), report_figures, verify_results. Tables land in outputs/reports/, plots in outputs/plots/, the five report figures in report/figures/. verify_results.R recomputes all 19 headline numbers from the raw CSV and stops on any mismatch (all matched in the submitted run, R 4.6.1).", size=12))
B.append(simple("Key files: main.R, requirements.R, scripts/unit1.R-unit4.R, scripts/problem_statements.R, scripts/report_figures.R, scripts/verify_results.R, functions/helper_functions.R, data/supermarket_sales.csv, PLAN.md, README.md, UNIT_MAPPING.md, oral_exam/viva_questions_and_functions.md.", size=12))
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
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120"/></w:pPr><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:b/><w:sz w:val="32"/><w:color w:val="000000"/></w:rPr></w:style>
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
