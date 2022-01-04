rule save_table:
    input:
        penguins_subset="out/data/processed/penguin_subset.rds",
    output:
        tab1="out/table/tab_1.txt",
    log:
        "logs/make_table.log",
    script:
        "../src/tables/make_table.R"

rule plot_figures:
    input:
        penguins_data="src/data/penguins.csv",
    output:
        fig1="out/figures/figure_1.pdf",
        fig2="out/figures/figure_2.pdf",
        data_subset="out/data/processed/penguin_subset.rds",
    params:
        title_label=["This is a fantastic title"],
        x1_label=["My great x label"],
        x2_label=["My amazing x label"],
    # message: "Rule {rule} is using this input: {input}",
    log:
        "logs/plot_figures.log",
    script:
        "../src/figures/plot_penguins.R"
