fMRI lag structure during waking up from early sleep stages
========================================================================================
Santiago Alcaide, Jacobo Sitt, Tomoyasu Horikawa, Alvaro Romano, Ana Carolina Maldonado, Agustín Ibanez, Mariano Sigman, Yukiyasu Kamitani, Pablo Barttfeld. In revision, Cortex


Abstract
========

The brain mechanisms by which we transition from sleep to a conscious state remain largely unknown in humans, partly because of the methodological challenges implied in its study. Here we study a dataset of waking up subjects and suggest that suddenly awakening from early sleep stages results from a two-stage process that involves a sequence of cortical and subcortical brain activity. During a first stage, subcortical and sensorimotor structures seem to preceed most cortical regions, followed by a fast, ignition-like activation of the whole brain – with frontal regions activating a little later than the rest of the brain. After this first wave of activation, a comparably slower and possibly mirror-reversed second stage might take place, in which cortical regions preceed subcortical structures and the cerebellum. This pattern of activation points to a key role of subcortical structures for the initiation and maintainance of conscious states.



Data
====

Data is available at https://github.com/KamitaniLab/HumanDreamDecoding


Scripts
=======

#### preprocessing scripts
- 'preprocessing/h52nii.m' #  reads original h5 files and saves .nii files
- 'preprocessing/preprocessing.m' # perform the preprocessing using spm12
- 'preprocessing/get_SCF_WM_signal.m' #  regress out covariables

#### GLM model
- 'glm_model/read_onsetsGLM.m' # get onset times
- 'glm_model/first_level_revision_cortex.m.m' # run first level models
- 'glm_model/second_level_revision_cortex.m.m' # run second level models
- 'glm_model/overlap_revision_cortex.m' # gets the overlap across subjects

#### time series analysis
- 'video/get_erp_images_revision_cortex.m' # 
- 'video/plot_waking_up.m' #
- 'video/video/movie.py' #
- 'video/make_movie.m' # these functions make the movie S1

#### lag analysis
- 'lags/get_vox_x_time.m' # reads nii images and extract ROIs time series
- 'lags/lags/get_td_matrices.m' # calculates lags


Dependencies
============

- SPM12
- Brainvisa/Anatomist


