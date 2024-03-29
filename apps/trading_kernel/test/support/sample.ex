defmodule TradingKernel.Sample do

  use ExUnit.CaseTemplate

  using do
    quote do
      @stock_results [
        %{date: "2010-06-30", highest_price: 30.42, lowest_price: 23.3,
          pre_close_price: 23.89},
        %{date: "2010-07-01", highest_price: 25.92, lowest_price: 20.27,
          pre_close_price: 23.83},
        %{date: "2010-07-02", highest_price: 23.1, lowest_price: 18.71,
          pre_close_price: 21.96},
        %{date: "2010-07-06", highest_price: 20.0, lowest_price: 15.83,
          pre_close_price: 19.2},
        %{date: "2010-07-07", highest_price: 16.63, lowest_price: 14.98,
          pre_close_price: 16.11},
        %{date: "2010-07-08", highest_price: 17.52, lowest_price: 15.57,
          pre_close_price: 15.8},
        %{date: "2010-07-09", highest_price: 17.9, lowest_price: 16.55,
          pre_close_price: 17.46},
        %{date: "2010-07-12", highest_price: 18.07, lowest_price: 17.0,
          pre_close_price: 17.4},
        %{date: "2010-07-13", highest_price: 18.64, lowest_price: 16.9,
          pre_close_price: 17.05},
        %{date: "2010-07-14", highest_price: 20.15, lowest_price: 17.76,
          pre_close_price: 18.14},
        %{date: "2010-07-15", highest_price: 21.5, lowest_price: 19.0,
          pre_close_price: 19.84},
        %{date: "2010-07-16", highest_price: 21.3, lowest_price: 20.05,
          pre_close_price: 19.89},
        %{date: "2010-07-19", highest_price: 22.25, lowest_price: 20.92,
          pre_close_price: 20.64},
        %{date: "2010-07-20", highest_price: 21.85, lowest_price: 20.05,
          pre_close_price: 21.91},
        %{date: "2010-07-21", highest_price: 20.9, lowest_price: 19.5,
          pre_close_price: 20.3},
        %{date: "2010-07-22", highest_price: 21.25, lowest_price: 20.37,
          pre_close_price: 20.22},
        %{date: "2010-07-23", highest_price: 21.56, lowest_price: 21.06,
          pre_close_price: 21.0},
        %{date: "2010-07-26", highest_price: 21.5, lowest_price: 20.3,
          pre_close_price: 21.29},
        %{date: "2010-07-27", highest_price: 21.18, lowest_price: 20.26,
          pre_close_price: 20.95},
        %{date: "2010-07-28", highest_price: 20.9, lowest_price: 20.51,
          pre_close_price: 20.55},
        %{date: "2010-07-29", highest_price: 20.88, lowest_price: 20.0,
          pre_close_price: 20.72},
        %{date: "2010-07-30", highest_price: 20.44, lowest_price: 19.55,
          pre_close_price: 20.35},
        %{date: "2010-08-02", highest_price: 20.97, lowest_price: 20.33,
          pre_close_price: 19.94},
        %{date: "2010-08-03", highest_price: 21.95, lowest_price: 20.82,
          pre_close_price: 20.92},
        %{date: "2010-08-04", highest_price: 22.18, lowest_price: 20.85,
          pre_close_price: 21.95},
        %{date: "2010-08-05", highest_price: 21.55, lowest_price: 20.05,
          pre_close_price: 21.26},
        %{date: "2010-08-06", highest_price: 20.16, lowest_price: 19.52,
          pre_close_price: 20.45},
        %{date: "2010-08-09", highest_price: 19.98, lowest_price: 19.45,
          pre_close_price: 19.59},
        %{date: "2010-08-10", highest_price: 19.65, lowest_price: 18.82,
          pre_close_price: 19.6},
        %{date: "2010-08-11", highest_price: 18.88, lowest_price: 17.85,
          pre_close_price: 19.03},
        %{date: "2010-08-12", highest_price: 17.9, lowest_price: 17.39,
          pre_close_price: 17.9},
        %{date: "2010-08-13", highest_price: 18.45, lowest_price: 17.66,
          pre_close_price: 17.6},
        %{date: "2010-08-16", highest_price: 18.8, lowest_price: 18.26,
          pre_close_price: 18.32},
        %{date: "2010-08-17", highest_price: 19.4, lowest_price: 18.78,
          pre_close_price: 18.78},
        %{date: "2010-08-18", highest_price: 19.59, lowest_price: 18.6,
          pre_close_price: 19.15},
        %{date: "2010-08-19", highest_price: 19.25, lowest_price: 18.33,
          pre_close_price: 18.77},
        %{date: "2010-08-20", highest_price: 19.11, lowest_price: 18.51,
          pre_close_price: 18.79},
        %{date: "2010-08-23", highest_price: 20.39, lowest_price: 19.0,
          pre_close_price: 19.1},
        %{date: "2010-08-24", highest_price: 19.71, lowest_price: 18.95,
          pre_close_price: 20.13},
        %{date: "2010-08-25", highest_price: 19.98, lowest_price: 18.56,
          pre_close_price: 19.2},
        %{date: "2010-08-26", highest_price: 20.27, lowest_price: 19.6,
          pre_close_price: 19.9},
        %{date: "2010-08-27", highest_price: 19.87, lowest_price: 19.5,
          pre_close_price: 19.75},
        %{date: "2010-08-30", highest_price: 20.19, lowest_price: 19.61,
          pre_close_price: 19.7},
        %{date: "2010-08-31", highest_price: 19.79, lowest_price: 19.33,
          pre_close_price: 19.87},
        %{date: "2010-09-01", highest_price: 20.69, lowest_price: 19.6,
          pre_close_price: 19.48},
        %{date: "2010-09-02", highest_price: 21.24, lowest_price: 20.31,
          pre_close_price: 20.45},
        %{date: "2010-09-03", highest_price: 21.3, lowest_price: 20.66,
          pre_close_price: 21.06},
        %{date: "2010-09-07", highest_price: 21.0, lowest_price: 20.5,
          pre_close_price: 21.05},
        %{date: "2010-09-08", highest_price: 20.95, lowest_price: 20.6,
          pre_close_price: 20.54},
        %{date: "2010-09-09", highest_price: 21.05, lowest_price: 20.69,
          pre_close_price: 20.9},
        %{date: "2010-09-10", highest_price: 20.93, lowest_price: 19.76,
          pre_close_price: 20.71},
        %{date: "2010-09-13", highest_price: 20.9, lowest_price: 20.5,
          pre_close_price: 20.17},
        %{date: "2010-09-14", highest_price: 21.6, lowest_price: 20.53,
          pre_close_price: 20.72},
        %{date: "2010-09-15", highest_price: 22.0, lowest_price: 20.79,
          pre_close_price: 21.12},
        %{date: "2010-09-16", highest_price: 23.16, lowest_price: 20.84,
          pre_close_price: 21.98},
        %{date: "2010-09-17", highest_price: 21.32, lowest_price: 19.8,
          pre_close_price: 20.94},
        %{date: "2010-09-20", highest_price: 21.35, lowest_price: 20.16,
          pre_close_price: 20.23},
        %{date: "2010-09-21", highest_price: 21.55, lowest_price: 20.67,
          pre_close_price: 21.06},
        %{date: "2010-09-22", highest_price: 20.95, lowest_price: 19.8,
          pre_close_price: 20.77},
        %{date: "2010-09-23", highest_price: 20.14, lowest_price: 19.5,
          pre_close_price: 19.87},
        %{date: "2010-09-24", highest_price: 20.19, lowest_price: 19.65,
          pre_close_price: 19.56},
        %{date: "2010-09-27", highest_price: 20.81, lowest_price: 20.05,
          pre_close_price: 20.1},
        %{date: "2010-09-28", highest_price: 21.49, lowest_price: 20.76,
          pre_close_price: 20.53},
        %{date: "2010-09-29", highest_price: 22.03, lowest_price: 21.13,
          pre_close_price: 21.4},
        %{date: "2010-09-30", highest_price: 22.15, lowest_price: 20.19,
          pre_close_price: 21.98},
        %{date: "2010-10-01", highest_price: 20.75, lowest_price: 20.31,
          pre_close_price: 20.41},
        %{date: "2010-10-04", highest_price: 21.17, lowest_price: 20.3,
          pre_close_price: 20.6},
        %{date: "2010-10-05", highest_price: 21.28, lowest_price: 21.01,
          pre_close_price: 20.99},
        %{date: "2010-10-06", highest_price: 21.26, lowest_price: 20.32,
          pre_close_price: 21.12},
        %{date: "2010-10-07", highest_price: 20.64, lowest_price: 20.34,
          pre_close_price: 20.46},
        %{date: "2010-10-08", highest_price: 20.79, lowest_price: 20.39,
          pre_close_price: 20.43},
        %{date: "2010-10-11", highest_price: 20.7, lowest_price: 20.07,
          pre_close_price: 20.43},
        %{date: "2010-10-12", highest_price: 20.28, lowest_price: 20.03,
          pre_close_price: 20.24},
        %{date: "2010-10-13", highest_price: 20.85, lowest_price: 20.36,
          pre_close_price: 20.24},
        %{date: "2010-10-14", highest_price: 21.03, lowest_price: 20.4,
          pre_close_price: 20.54},
        %{date: "2010-10-15", highest_price: 20.9, lowest_price: 20.25,
          pre_close_price: 20.75},
        %{date: "2010-10-18", highest_price: 20.64, lowest_price: 20.22,
          pre_close_price: 20.54},
        %{date: "2010-10-19", highest_price: 20.41, lowest_price: 20.0,
          pre_close_price: 20.23},
        %{date: "2010-10-20", highest_price: 20.69, lowest_price: 20.04,
          pre_close_price: 20.05},
        %{date: "2010-10-21", highest_price: 20.95, lowest_price: 20.45,
          pre_close_price: 20.65},
        %{date: "2010-10-22", highest_price: 20.93, lowest_price: 20.55,
          pre_close_price: 20.75},
        %{date: "2010-10-25", highest_price: 20.98, lowest_price: 20.73,
          pre_close_price: 20.72},
        %{date: "2010-10-26", highest_price: 21.87, lowest_price: 20.51,
          pre_close_price: 20.85},
        %{date: "2010-10-27", highest_price: 21.38, lowest_price: 20.65,
          pre_close_price: 21.36},
        %{date: "2010-10-28", highest_price: 21.5, lowest_price: 20.96,
          pre_close_price: 21.0},
        %{date: "2010-10-29", highest_price: 21.85, lowest_price: 21.05,
          pre_close_price: 21.19},
        %{date: "2010-11-01", highest_price: 22.75, lowest_price: 21.31,
          pre_close_price: 21.84},
        %{date: "2010-11-02", highest_price: 21.88, lowest_price: 21.05,
          pre_close_price: 21.41},
        %{date: "2010-11-03", highest_price: 22.5, lowest_price: 21.16,
          pre_close_price: 21.25},
        %{date: "2010-11-04", highest_price: 25.33, lowest_price: 22.15,
          pre_close_price: 21.77},
        %{date: "2010-11-05", highest_price: 24.97, lowest_price: 23.72,
          pre_close_price: 24.9},
        %{date: "2010-11-08", highest_price: 25.0, lowest_price: 24.03,
          pre_close_price: 24.44},
        %{date: "2010-11-09", highest_price: 25.69, lowest_price: 24.05,
          pre_close_price: 24.98},
        %{date: "2010-11-10", highest_price: 29.97, lowest_price: 24.05,
          pre_close_price: 24.63},
        %{date: "2010-11-11", highest_price: 29.1, lowest_price: 27.33,
          pre_close_price: 29.36},
        %{date: "2010-11-12", highest_price: 30.5, lowest_price: 28.07,
          pre_close_price: 28.04}
      ]
    end
  end
end