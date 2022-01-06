rule make_report:
    input:
        "../results/data/processed/penguin_subset.rds"
    output:
        "../results/reports/report.html"
    params:
        data=config["raw_data"],
        second_param=rules.save_table.output.tab1
    script:
        "../scripts/reports/report.Rmd"
