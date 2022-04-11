#!/usr/bin/env python3
import joypy
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib import cm
import matplotlib
import numpy as np

saveLocation = "/path to save/plots/windowJoy"

runs = ["/path to data/data/windowJoy/E_albens~E_sideroxylon.summary",
    "/path to data/data/windowJoy/E_albens~new_mell.summary",
    "/path to data/data/windowJoy/E_sideroxylon~E_albens.summary",
    "/path to data/data/windowJoy/E_sideroxylon~new_mell.summary",
    "/path to data/data/windowJoy/new_mell~E_albens.summary",
    "/path to data/data/windowJoy/new_mell~E_sideroxylon.summary"]


for currRun in runs:
    name = currRun.split("/")[-1].split(".")[0]
    print(name)

    lengths=pd.read_csv(currRun, header = 0)
    lengths['pc'] = pd.to_numeric(lengths['pc'],errors='coerce')

    fig, axes = joypy.joyplot(lengths, by="size", column="pc", range_style='own', overlap=2,
        grid="y", linewidth=.85, legend=False, fade=False, figsize=(10,8), tails=0.15, kind="kde", title=name)
    
    xticks = [float(i.get_text()) for i in axes[-1].get_xticklabels()]
    newTicks = []
    for ttt in xticks:
        newTicks.append("{}%".format(int(ttt* 100)))
    axes[-1].set_xticklabels(newTicks)

    plt.savefig("{}/{}.svg".format(saveLocation, name), bbox_inches='tight', dpi=1200)