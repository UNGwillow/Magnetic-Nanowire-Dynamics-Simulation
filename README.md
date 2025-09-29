# Magnetic Nanorod Alignment Dynamics & EMT Property Prediction Simulation

## 📝 Overview

This MATLAB code simulates the 2D rotational alignment dynamics of magnetic nanorod fillers dispersed in a viscous fluid under an external magnetic field. Furthermore, it predicts the relative changes in the composite's effective conductivity/resistance and permittivity/capacitance based on the calculated alignment state using Effective Medium Theory (EMT, Maxwell-Garnett type). This simulation was developed to understand the working principle and predict the performance of magnetic field-responsive flexible sensors.

## ✨ Key Features

* **2D Rotational Dynamics Simulation:**
    * Utilizes the Overdamped Langevin equation model.
    * Considers magnetic torque, viscous drag torque, and Brownian motion torque.
    * Applies the Euler-Maruyama numerical integration method.
* **Effective Medium Theory (EMT) Application:**
    * Calculates filler magnetic moment using Mol% and VSM data.
    * Calculates filler volume fraction based on the Wt% recipe.
    * Computes limit values (fully aligned/perpendicular) using Maxwell-Garnett (MG) type models.
    * Calculates the order parameter ($S_2 = \langle \cos^2 \theta_{rel} \rangle$).
    * Predicts relative changes in conductivity/resistance and permittivity/capacitance compared to the random state (using linear interpolation approximation).
* **Visualization:**
    * Optional animation of the nanorod alignment process.
    * Plot of individual nanorod angle changes over time.
    * Plot of order parameter ($S_2$) and relative property changes over time.
    * Plot of relative property changes as a function of the order parameter ($S_2$).

## 📁 Code Structure

* `nanorod_alignment_emt_simulation.m`: Main MATLAB script file.

## 🚀 How to Use

1.  Open the `nano_alignment_emt_simulation.m` script in your MATLAB environment.
2.  Modify the values in the `User Input Parameters` section at the top of the script according to your actual experimental conditions and measurements/estimations.
    * Filler information (mol%, VSM value, dimensions, etc.)
    * Fabrication recipe (wt%)
    * Simulation conditions (magnetic field, viscosity, temperature, time, etc.)
    * Material properties for EMT calculation ($\sigma_m, \sigma_f, \epsilon'_m, \epsilon'_f$)
3.  Run the script.
4.  Result plots will be generated, and an animation may be displayed depending on the settings.

## 🔬 Model Details

* **Dynamics:** Overdamped rotational Langevin equation, Euler-Maruyama method.
* **EMT Limit Values:** Maxwell-Garnett (MG) type model (considering ellipsoidal depolarization factors).
* **Intermediate State Approximation:** Linear interpolation based on the order parameter ($S_2$).

## 🔧 Dependencies

* MATLAB (Tested version: R2023b)

## 🤝 Contributing

This code was developed as part of a Capstone Design project. Suggestions for improvements or bug reports are always welcome.
## 📜 License

This project is distributed under the [MIT License](LICENSE).
