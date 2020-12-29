
clear 
close all

cd /home/pablo/Escritorio/

header = spm_vol('myMask1.img');
s1 = spm_read_vols(header);

header = spm_vol('myMask2.img');
s2 = spm_read_vols(header);

header = spm_vol('myMask3.img');
s3 = spm_read_vols(header);

S = logical(s1) + logical(s2)+ logical(s3);

header.fname = 'overlap.nii';
spm_write_vol(header,S);