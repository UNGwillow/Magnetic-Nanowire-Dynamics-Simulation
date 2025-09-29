# Magnetic Nanorod Dynamics & Permittivity Simulation

A MATLAB script to simulate the alignment dynamics of magnetic nanorods and predict the resulting change in the composite's effective permittivity.

## 📝 Overview

This script simulates the 2D rotational alignment of magnetic nanorod fillers dispersed in a viscous fluid under an external magnetic field. It uses the **Langevin equation** to model the rotational dynamics of individual rods, considering both magnetic torque and thermal (Brownian) motion.

Subsequently, it employs the **Effective Medium Theory (EMT)** to predict how the alignment of these rods affects the overall effective permittivity (and thus capacitance) of the composite material. This simulation was developed to understand the working principle and predict the performance of the magnetic field-responsive flexible sensor from our capstone design project.

## ✨ Key Features

- **Langevin Dynamics Simulation:** Models the time-dependent orientation of multiple nanorods using the Euler-Maruyama numerical method.
    
- **Effective Medium Theory (EMT):** Predicts the composite's effective permittivity based on filler properties and alignment state (S2​=⟨cos2θ⟩).
    
- **Lab-Based Parameters:** Easily calculates key simulation inputs (e.g., filler magnetic moment, volume fraction) directly from experimental data like `mol%`, `wt%`, and VSM values.
    
- **Configurable Outputs:** Includes a simple `DEBUG` flag to turn detailed command window printouts on or off.
    

## 🚀 How to Use

1. **Clone the Repository:**
    
    Bash
    
    ```
    git clone https://github.com/your-username/your-repo-name.git
    ```
    
2. **Set Parameters:** Open the `.m` script in MATLAB. All user-configurable variables are located in the **`USER INPUT PARAMETERS`** section at the top of the file. Modify these values to match your specific materials and experimental conditions.
    
    Matlab
    
    ```
    %% --- USER INPUT PARAMETERS ---
    % ...
    params.mol_Fe3O4 = 10;        % mol% of Fe3O4 on BTO fillers. 
    params.sigma_s   = 4;         % Saturation magnetization of the filler (emu/g).
    % ... and so on
    ```
    
3. **Run the Script:** Run the script from the MATLAB editor or command window.
    

## 📊 Generated Outputs

Upon successful execution, the script will generate the following files in the project directory:

- `plot_alignment_dynamics.png`: A plot showing the orientation angle of representative nanorods over time.
    
- `plot_capacitance_change.png`: A plot showing the predicted relative change in capacitance (%) over time, calculated relative to the initial random state.
    

## 🔧 Dependencies

- MATLAB (tested on version R2021b and later).
    
- No special toolboxes are required; the script runs on a base installation of MATLAB.
    

## 📜 License

This project is distributed under the [MIT License](https://www.google.com/search?q=LICENSE).
