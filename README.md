# vaspup2.0

A collection of `bash` scripts to efficiently generate and analyse VASP
convergence-testing calculations.
The original [vaspup](https://github.com/utf/vaspup) was developed by [Alex Ganose](https://github.com/utf)
for ground-state energy convergence testing and `POTCAR` generation.

## vaspup2.0 Functionality includes

- Convergence testing of ground-state energy with respect to `ENCUT` (plane wave kinetic energy cutoff)
  (i.e. basis set size) and **_k_**-point density (specified in the `KPOINTS` file).
- Convergence testing of atomic forces with respect to `ENCUT` (plane wave kinetic energy cutoff)(i.e. 
  basis set size) and **_k_**-point density (specified in the `KPOINTS` file), which uses the `checkforce` 
  script written by [Dr Ben Morgan](https://morgan-group-bath.github.io/) 🙌 
- Convergence testing of $\epsilon_{Ionic}$ (ionic contribution to the static dielectric constant
  $\epsilon_0 = \epsilon_{Ionic} + \epsilon_{Optic}$) with respect to `ENCUT` and **_k_**-point density, 
  calculated with Density Functional Perturbation Theory (DFPT).
- Convergence testing of $\epsilon_{Optic}$ (optical / high-frequency dielectric constant) with respect to `NBANDS`, calculated with using the method of [Furthmüller et al.](https://journals.aps.org/prb/abstract/10.1103/PhysRevB.73.045112) (`LOPTICS = True`).

## Installation

Installation is quite simple, just clone this git repository and update your `PATH` to include the
location of the bin folder.

```bash
git clone https://github.com/kavanase/vaspup2.0
cd vaspup2.0/bin && chmod 777 *
echo 'export PATH="${HOME}/path/to/vaspup2.0/bin:${PATH}"' >> ~/.bashrc
```

Replace `path/to` with the location of the `vaspup2.0` on **your** system. <!-- This may seem obvious, but you'd be surprised... -->

## Implementation

### Ground-State Energy Convergence

To quickly set up a ground-state energy convergence test, the following steps are required:

- Create a folder named `input`, containing `INCAR`, `KPOINTS`, `POSCAR`, and `POTCAR` VASP input files,
a jobscript file (`job`) and a `CONFIG` file. Example `CONFIG` and `INCAR` files are provided in
the [input](input) directory named `CONFIG`
and `energy_INCAR` respectively. _(Note: Rename `energy_INCAR` to `INCAR`)_.
The directory structure should match the below:

```bash
./<Convergence Testing Directory (run script from here)>
    ./input
        /INCAR
        /KPOINTS
        /POSCAR
        /POTCAR
        /CONFIG
        /job
```

- Customise the CONFIG file as you wish (specifying `ENCUT` and **_k_**-point convergence parameters
and (optionally) the `name` to append to each jobname).

- Run the `generate-converge` executable from the directory **above** the `input` directory.
A series of folders will be created, with the folder names matching the calculation settings.
For example, the `cutoff_converge/e450` folder will contain the `ENCUT = 450 eV` calculation and
the `kpoint_converge/k664` folder will contain the calculation with a **_k_**-mesh of
$6\times6\times4$.

Note that `vaspup2.0` uses the SGE `qsub` job submission command by default, but this can easily be modified in the bash scripts.

- Once the calculations have finished running, the `data-converge` script can be used to extract the
total energies from the VASP output. This script will print the convergence data to the terminal
(as shown below) as well as saving to a file named `Convergence_Data`. The `data-converge` script
should be run separately within the folders named `kpoint_converge` and `cutoff_converge`.

Example output from `data-converge`:

![](Examples/data-converge_example.png)

Note that, for semiconductor materials, a denser **_k_**-point mesh is typically required for accurate density of states and optical absorption spectra. See [Density of States & Absorption Spectrum Convergence](#density-of-states-and-absorption-spectrum-convergence) examples below.

### Ionic Dielectric Constant (DFPT) Convergence

The calculated value for the ionic contribution to the static dielectric constant
$\epsilon_{Ionic}$
($\epsilon_0 = \epsilon_{Ionic} + \epsilon_{Optic}$) is quite sensitive to
both the plane wave kinetic energy cutoff `ENCUT` and the **_k_**-point density, with more expensive parameter values necessary (relative to ground-state-energy-converged values) due to the requirement of accurate ionic forces. This is demonstrated
in the [Dielectric_Constants_Convergence](Dielectric_Constants_Convergence.ipynb) Jupyter notebook.
Thus, calculation of the $\epsilon_{Ionic}$ should be accompanied by convergence tests with respect to these parameters.

To quickly set up a convergence test for $\epsilon_{Ionic}$,
the following steps are required (note similarity to ground-state energy convergence procedure):

- Create a folder named `input`, containing appropriate `INCAR`, `KPOINTS`, `POSCAR`, and `POTCAR`
files, in addition to a `CONFIG` file. Example `CONFIG` and `INCAR` files are provided in
the [input](input) directory named `CONFIG`
and `dfpt_INCAR` respectively. _(Note: Rename `dfpt_INCAR` to `INCAR`)_.
The directory structure should match the below:

```bash
./<DFPT Convergence Testing Directory (run script from here)>
    ./input
        /INCAR
        /KPOINTS
        /POSCAR
        /POTCAR
        /CONFIG
        /job
```

- Customise the CONFIG file as you wish (specifying `ENCUT` and **_k_**-point convergence parameters
and (optionally) the `name` to append to each jobname).

- Run the `generate-converge` executable from the directory **above** the `input` directory.
A series of folders will be created, with the folder names matching the calculation settings.

- Once the calculations have finished running, the `dfpt-data-converge` script can be used to
extract the values for the ionic contribution to the static dielectric constant
$\epsilon_{Ionic}$ (specifically the
diagonal terms from the `MACROSCOPIC STATIC DIELECTRIC TENSOR IONIC CONTRIBUTION` in the VASP
`OUTCAR` files). This script will print the convergence data to the terminal
(as shown below) as well as saving to a file named `Convergence_Data`. The `data-converge` script
should be run separately within the folders named `kpoint_converge` and `cutoff_converge`.

Example output from `dfpt-data-converge`:

![](Examples/dfpt-data-converge_example.png)

**Beware `Warning: PSMAXN too small for non-local potential` (in `OUTCAR` and `stdout` files) at too high `ENCUT`!**
It has been observed that when too large an `ENCUT` is used (depending on the 'hardness' of the
pseudopotentials - determined by `ENMAX` in the `POTCAR` files) VASP appears to run as normal
(but with `Warning: PSMAXN too small for non-local potential` printed in the `OUTCAR` and `stdout`
files), but the results for $\epsilon_{Ionic}$ begin to diverge.
This is demonstrated in the [Dielectric_Constants_Convergence](Dielectric_Constants_Convergence.ipynb) Jupyter notebook
("Region of Shit" red-zones).

**Note that this `INCAR` is for calculating the _ionic contribution to the dielectric constant_. If you want to calculate other properties such as the elastic constant, you will need to change `INCAR` tages (e.g. `ISIF = 3` for elastic constants).**

### Optical Dielectric Constant Convergence

The calculated value for the optical dielectric constant
$\epsilon_{Optic}$
($\epsilon_0 = \epsilon_{Ionic} + \epsilon_{Optic}$) is quite sensitive to
the number of electronic bands included in the calculation (`NBANDS`), with a large number of
unoccupied bands required for convergence, as demonstrated in the
[Dielectric_Constants_Convergence](Dielectric_Constants_Convergence.ipynb) Jupyter notebook.
Thus, calculation of the $\epsilon_{Optic}$ should be accompanied by a convergence test with respect to this parameter.
Note that the calculated value for $\epsilon_{Optic}$ is typically not sensitive to either the plane wave kinetic energy cutoff `ENCUT` or the **_k_**-point density, **assuming you are using values that are well-converged with respect to
the ground-state energy!**
Additionally, note that the_optical absorption spectrum_, as with the density of states, typically requires a denser k-point mesh to give a converged result, than for total energy or optical dielectric constant. See [Density of States & Absorption Spectrum Convergence](#density-of-states-and-absorption-spectrum-convergence) examples below.

To quickly set up an `NBANDS` convergence test for $\epsilon_{Optic}$,
the following steps are required:

- Create a folder named `input`, containing appropriate `INCAR`, `KPOINTS`, `POSCAR`, and `POTCAR`
files, in addition to a `CONFIG` file. Example `CONFIG` and `INCAR` files are provided in
the [input](input) directory named
`nbands_CONFIG` and `nbands_INCAR` respectively. _(Note: Rename to `CONFIG` and `INCAR`)_.
The directory structure should match the below:

```bash
./<NBANDS Convergence Testing Directory (run script from here)>
    ./input
        /INCAR
        /KPOINTS
        /POSCAR
        /POTCAR
        /CONFIG
        /job
```

- Customise the CONFIG file as you wish (specifying the `NBANDS` convergence parameters
and (optionally) the `name` to append to each jobname).

- Run the `nbands-generate-converge` executable from the directory **above** the `input` directory.
A series of folders will be created, with the folder names matching the calculation settings.
For example, the `nbands_converge/nbands_100` folder will contain the `NBANDS = 100` calculation

- Once the calculations have finished running, the `nbands-epsopt-data-converge` script can be run
in the `nbands_converge` directory to extract the values for the optical dielectric constant
$\epsilon_{Optic}$ (specifically the
X, Y and Z components of the `frequency dependent      REAL DIELECTRIC FUNCTION` in the VASP
`OUTCAR` files). This script will print the convergence data to the terminal
(as shown below) as well as saving to a file named `NBANDS_Convergence_Data`.

Example output from `nbands-epsopt-data-converge`:

![](Examples/nbands-epsopt-data-converge_example.png)

#### Note

For accurate calculations of the optical dielectric constant
$\epsilon_{Optic}$, it is
recommended to use Hybrid DFT (such as the HSE06 functional) or a similar level of theory.
However, in the example `nbands_INCAR` file, the PBEsol GGA DFT functional is used for the purpose
of efficient use of computational resources during convergence testing.
It is advised to use this cheaper lower-level theory in order to obtain a good estimate
of the required number of electronic bands (`NBANDS`) for a well-converged value of
the optical dielectric constant. Once the required `NBANDS` has been determined from the GGA DFT
convergence test, it can then be used in a single Hybrid DFT calculation of
$\epsilon_{Optic}$.

This procedure assumes similar convergence behaviour (wrt `NBANDS`) within Hybrid DFT as for GGA DFT.
This is a reasonable assumption in this case, as GGA DFT tends to underestimate band gaps, implying
that it would require a larger number of electronic bands to cover the required energy range for
convergence of $\epsilon_{Optic}$,
than for Hybrid DFT.
Hence, a well-converged value of `NBANDS` for GGA DFT should certainly correspond to a
well-converged value for Hybrid DFT, as has been observed.

Additionally, it should be noted that VASP automatically rounds `NBANDS` to the nearest multiple
of `NPAR` = # of cores / (`NCORE` * `KPAR`). So ideally these parameters should be set so that
`NPAR` is a factor of the `NBANDS` increment in the `CONFIG` file.

##### `syntax error`

If `data-converge` gives the output `(standard_in) 1: syntax error`, then it means that `vaspup2.0`
is having trouble parsing some or all of the calculation results. Typically, this means that some
or all of the calculations failed, and so the solution is to look at the output files of the
calculations and decide what needs to be changed for the caculations to be successful (e.g. reduce
`NCORE` in `INCAR` to avoid parallelisation errors, increase `job` CPU hours to allow calculation
to converge in time etc.), then re-run `generate-converge`. Also, if only some of the calculations
failed, it is usually obvious from the output of `data-converge` in this case (Hint: they're the
ones with batshit crazy energies), now go fix those calculations!

##### `integer expression expected`

If you have both `vaspup2.0` and the older `vaspup` on your `$PATH`, and are using the `vaspup2.0`
`CONFIG` files, you may encounter the following error:

```bash
/home/path/to/src/vaspup/bin/generate-converge: line 16: [: : integer expression expected
```

In this case, the advice is to remove the older `vaspup` commands from your `$PATH` and/or
remove the `vaspup` folder from your system.

Alternatively, this error can occur if a required tag (`conv_encut`, `conv_kpoint`, `run_vasp` etc.)
in the `CONFIG` file is commented out.

## Tips

For **_k_**-point convergence testing (of ground-state energy or
$\epsilon_{Ionic}$),
the **_k_**-point meshes to be tested must be explicitly provided in the `CONFIG` file
(to allow for non-cubic systems), as below:

```bash
kpoints="3 3 2,4 4 3,5 5 4,6 6 5,7 7 6,8 8 7,9 9 8" # All the kpoints meshes
# you want to try, separated by a comma
```

Instead for convenience, one can auto-generate the **_k_**-points using the `kgs_gen_kpts` script:

```bash
kgs_gen_kpts
```

This will auto-populate the `CONFIG` file with the **_k_**-point meshes corresponding to real-space cutoff distances 
between 5 Å and 25 Å (default values – typically good for semiconductors and insulators, may need to be increased for metals). 
These real-space cutoff distances can be specified as arguments to the script in the format 
`kgs_gen_kpts {min_real_space_cutoff} {max_real_space_cutoff}`, if they need to be changed.

```bash
kgs_gen_kpts -h  # "-h" shows help message
```

```txt
vaspup2.0 - Seán Kavanagh (sean.kavanagh.19@ucl.ac.uk), 2023
Usage: in 'input' directory with POSCAR and CONFIG files present, and 'kpoints' mentioned in CONFIG file.
$ kgs_gen_kpts {min_real_space_cutoff} {max_real_space_cutoff}
(Default: min = 5, max = 25 – max likely needs to be increased for metals)
```

This script uses the excellent [kgrid](https://github.com/WMD-group/kgrid) package developed by Adam Jackson to generate appropriate **_k_**-point meshes corresponding to a given real-space length cutoff (in Angstrom).

A general recommendation for DFT-calculated dielectric constants is to converge the predicted value to within 0.1, at least, though this of course depends on the target property!
For example, this criterion typically gives a well-converged optical absorption spectrum, something which can be quickly verified visually, using:

```bash
for i in nbands_*; do cd $i; sumo-optplot --ymax 2e6 --xmax 4; cd ..; done
```

then look at the `absorption.pdf` files in each directory.

## Density of States and Absorption Spectrum Convergence

While the total energy and high-frequency dielectric constant $\epsilon_{Optic}$ were converged to within 1 meV/atom and 0.1 respectively at a **_k_**-point mesh of 3x3x3, convergence of the density of states and absorption spectrum are not reached until much higher **_k_**-point densities of 6x6x6.
Note that use of tetrahedron smearing (`ISMEAR = -5`) will typically give better convergence of the density of states (i.e. converged at lower k-point densities) than Gaussian smearing (`ISMEAR = 0`), and is absolutely essential for optical absorption calculations.

![](Examples/Cs2SnI6_dos.gif)

![](Examples/Cs2SnI6_absorption.gif)

## Disclaimer

This program is not affiliated with VASP. This program is made available under the MIT License; you are free to modify and use the code, but do so at your own risk.
