# sulcimap

This library provides an R function **`plot_sulci()`** to visualize **sulcal measures** based on BrainVISA output and the ENIGMA sulcal protocol.  

It generates publication-ready plots of sulcal statistics/values for **492 sulcal measures**, including:  
- **123 sulci** across the whole brain (62 left, 61 right)  
- **4 sulcal types** per sulcus:  
  - Opening (width) → `.opening`  
  - Depth → `.meandepth_native`  
  - Surface area → `.surface_native`  
  - Length → `.hull_junction_length_native`  

The plots can be generated for each measure separately or all four at once.

**References & links**  
- BrainVISA: https://brainvisa.info/web/  
- ENIGMA Imaging Protocols (ENIGMA-Sulci): https://enigma.ini.usc.edu/protocols/imaging-protocols/

---

## Installation

```r
# install.packages("remotes")
remotes::install_github("mhnshf/sulcimap")
library(sulcimap)
```
---

## Input Data
# You can also load a CSV shipped with the package.

The input must be a **CSV file** with **two columns**:

| Sulcus                                | Value |
|---------------------------------------|-------|
| S.C._left.opening                     | 5.31  |
| S.C._left.meandepth_native            | 1.27  |
| S.C._left.surface_native              | 2.42  |
| S.C._left.hull_junction_length_native | 1.96  |
| S.C._right.opening                    | 2.28  |
| ...                                   | ...   |

- `Sulcus`: must contain all **492 sulci name tags** from **BrainVISA ENIGMA output**.  
- The naming convention is: `Sulcus_Hemisphere.MeasureType`  
  **Examples:**
  - `S.C._left.opening`
  - `S.C._right.meandepth_native`
  - `F.I.P._left.surface_native`
  - `F.I.P._right.hull_junction_length_native`

If a sulcus is **not available**, assign the value **0**.  

👉 For the complete list of sulcus name tags and input sample, see [`template_input.csv`](template_input.csv) and [`input_data_example.csv`](input_data_example.csv)

---

## Usage

See documentation for a full example of using `plot_sulci()` function:

```r
plot_out <- plot_sulci(
  sulcus_values = df,
  palette       = "gyr",
  value_range   = NULL,
  save_dir      = "output",
  measure       = "all",
  show_colorbar = TRUE,
  caption       = expression(-log[10](p))
)
```
**Argument details**

- **`sulcus_values`** *(data.frame)*  
  A two-column data frame with `Sulcus` and `Value`. `Sulcus` must include all 492 BrainVISA-style tags (left/right × 4 types). Missing types should have `Value = 0`.

- **`palette`** *(character)*  
  The color palette used to map values and colorbar.  
  Common options include `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, `"cividis"`, `"heat"`, `"gyr"` (grey→yellow→reds) (depending on your implementation). Choose one string.

- **`value_range`** *(numeric length-2 or `NULL`, default `NULL`)*  
  Controls the color scale.  
  - `NULL`: auto-scale from the min/max of provided values.  
  - `c(min, max)`: fix the scale across plots/conditions for comparability.

- **`save_dir`** *(character or `NULL`, default `NULL`)*  
  Directory where the plot image(s) are saved.  
  - If the folder does not exist, it will be created.  
  - Set to `NULL` to skip saving and only return the plot object.

- **`measure`** *(character)*  
  What to plot:  
  - `"all"`: generate all four measures in one go.  
  - `"opening"`, `"depth"`, `"surface"`, `"length"`: generate a single-measure plot.

- **`show_colorbar`** *(logical)*  
  Show or hide the color bar on the figure.

- **`caption`** *(character)*  
  Label displayed under/along the color bar. You can pass a plain string (e.g., `"P-value"`) or an R expression for mathematical notation.

---

## Output Examples
- **All measures combined** (`measure = "all"`)  
  ![All Measures](output/example_all.png)

- **Opening (width)** (`measure = "opening"`)  
  ![Opening](output/example_opening.png)

---

## Citation

If you use this code in your research, please cite:

> *sulcimap: Plot sulcal measures on brain. GitHub repository (2025). https://github.com/mhnshf/sulcimap*

---

## License

MIT License (see LICENSE).

---

## Acknowledgments

- ENIGMA Consortium – sulcal-based morphometry protocol.  
- BrainVISA – Neuroimaging software platform for sulcal-based morphometry.
