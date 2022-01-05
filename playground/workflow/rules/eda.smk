rule save_table:
    input:
        penguins_subset="../results/data/processed/penguin_subset.rds",
    output:
        tab1="../results/tables/tab_1.txt",
    log:
        "../results/logs/save_table.log",
    script:
        "../scripts/tables/make_table.R"


rule save_figures:
    input:
        penguins_data="scripts/data/penguins.csv",
    output:
        fig1="../results/plots/figure_1.pdf",
        fig2="../results/plots/figure_2.pdf",
        data_subset="../results/data/processed/penguin_subset.rds",
    params:
        title_label=["This is a fantastic title"],
        x1_label=["My great x label"],
        x2_label=["My amazing x label"],
    # message: "Rule {rule} is using this input: {input}",
    log:
        "../results/logs/save_figures.log",
    script:
        "../scripts/figures/plot_penguins.R"
