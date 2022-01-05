
rule make_report:
    input:
        "../results/data/processed/penguin_subset.rds",
        "../results/plots/figure_2.pdf"
    output:
        "../results/reports/report.html"
    script:
        "../scripts/reports/report.Rmd"
