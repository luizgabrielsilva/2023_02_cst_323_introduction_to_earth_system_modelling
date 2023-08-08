import pandas as pd
import numpy as np
from matplotlib import pyplot as plt

import pathlib


class Experiment:
    def __init__(self,
                 experiment_name,
                 project_path,
                 filename,
                 dimension):
        self.experiment_name = experiment_name
        self.project_path = project_path
        self.filename = filename
        self.dimension = dimension
        
    
    def get_data(self):
        data_path = self.project_path / pathlib.Path("data")
        self.data = pd.read_csv(filepath_or_buffer=data_path / pathlib.Path(self.filename),
                           sep=";",
                           usecols=["empty", "forest"])
    
    def process_data(self):
        self.data.forest = self.data.forest / self.dimension ** 2
        self.processed_data = self.data.groupby("empty").agg("mean")
        
        self.processed_data = self.processed_data.reset_index().rename(columns={"forest": "forest_mean"})
        
    def plot_results(self, color="red", label="Proportion of forest",
                     expected_forest=True, ci=False, opt=False, rng=None, ax=None):
        """Plot the results of an experiment
        
        Parameters
        ----------
        color: str - default is red
            color for line of results
        ci: bool - default is False
            Plot confidence intervals - bootstrap (scipy default options)
        opt: bool - default is False
            Plot vertical line for optimal value of empty probability
        rng: Optional - defalt is None
            Define random number generator for bootstrap
        """
        
        
        if not rng:
            rng = np.random.default_rng()
        
        if not ax:
            fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(5,5))

        if expected_forest:
            ax.plot(self.processed_data["empty"],
                    1 - self.processed_data["empty"],
                    "--",
                    color="green",
                    markerfacecolor="none",
                    linewidth=1,
                    label="Exp(Initial Forest)")
        
        ax.plot(self.processed_data["empty"],
                self.processed_data.forest_mean,
                "--o",
                color=color,
                markerfacecolor="none",
                markersize=4,
                linewidth=1,
                label=label)
        
        if opt:
            argmax = np.argmax(self.processed_data.forest_mean.values)
            opt_empty_prob = self.processed_data["empty"].values[argmax]
            max_forest = self.processed_data.forest_mean.values[argmax]
            
            ax.axvline(x=opt_empty_prob,
                       ymin=0,
                       ymax=1,
                       color="blue",
                       linestyle="dashed",
                       linewidth=1,
                       label=f"Optimum probability of empty cells: {opt_empty_prob}")
        
        if ci:
            low = []
            high = []
            std_error = []
            
            for p in self.processed_data["empty"].unique():
                res = bootstrap((self.data.loc[self.data["empty"]==p, "forest"].values,),
                                np.mean, confidence_level=0.95, random_state=rng)
                
                low.append(res.confidence_interval[0])
                high.append(res.confidence_interval[1])
                std_error.append(res.standard_error)
            
            
            ax.fill_between(self.processed_data["empty"],
                            y1=high,
                            y2=low, 
                            color="red",
                            alpha=0.4)
            
        
        ax.set_xlabel("Probability of empty cells")
        ax.set_ylabel("Proportion of Forest")
        
        ax.legend()