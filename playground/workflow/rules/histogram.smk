rule make_histogram:
    input:
        penguins_data="scripts/data/penguins.csv"
    output:
        hist1="../results/plots/hist_1.pdf"
    params:
        title_label=["This is my fantastic title"],
        x_label=["This is my fantastic x label"]
    # message: "Rule {rule} is using this input: {input}",
    log:
        "../results/logs/make_histogram.log"
    script:
        "../scripts/figures/hist_penguins.R"
