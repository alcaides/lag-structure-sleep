# -*- coding: cp1252 -*-
from sys import *
from random import uniform
from random import randint
from random import Random
import time
from soma import aims
import os
import pickle
import anatomist.direct.api as ana
a = ana.Anatomist()

component = 'firstcomponent'; # 'firstcomponent / secondcomponent';
subject   = '2'; 

if component == 'firstcomponent' and subject == '1':
	MIN = -1.5 
	MAX = 1.0
	comp = '1'

if component == 'firstcomponent' and subject == '2':
	MIN = -2.0 
	MAX = 1.5
	comp = '1'

if component == 'firstcomponent' and subject == '3':
	MIN = -2.0 
	MAX = 1.0
	comp = '1'

#######
if component == 'secondcomponent' and subject == '1':
	MIN = -1.0 
	MAX = 1.5
	comp = '2'

if component == 'secondcomponent' and subject == '2':
	MIN = -1.5 
	MAX = 1.5
	comp = '2'

if component == 'secondcomponent' and subject == '3':
	MIN = -1.0 
	MAX = 1.0
	comp = '2'




a.config()[ 'linkedCursor' ] = 0

t1  = a.loadObject('/home/pablo/disco/utiles/toolboxes/spm12/canonical/'+'single_subj_T1.nii')


image = a.loadObject('/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro/results/lags/TD/' + component + '/rAverage_'+ component +'_subject' + subject + '.nii')
image.setPalette("tvalues100-200-100", minVal=MIN, maxVal=MAX,absoluteMode=True)

fusion2d=a.fusionObjects([t1,image],"Fusion2DMethod")

w2d = a.createWindow( 'Axial' )
a.addObjects(fusion2d, w2d)
s = 96 
w2d.moveLinkedCursor((0, 0, s, 0))

a.execute( 'WindowConfig', windows=[w2d], snapshot='/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/figures_rev_cortex/lags/subject' + subject +'/comp' +comp + '/1.png')

w2d = a.createWindow( 'Sagittal' )
a.addObjects(fusion2d, w2d)
s=105
w2d.moveLinkedCursor((s, 0, 0, 0))
a.execute( 'WindowConfig', windows=[w2d], snapshot='/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/figures_rev_cortex/lags/subject' + subject +'/comp' +comp + '/2.png')

w2d = a.createWindow( 'Coronal' )
s=105
a.addObjects(fusion2d, w2d)
w2d.moveLinkedCursor((0, s, 0, 0))
a.execute( 'WindowConfig', windows=[w2d], snapshot='/home/pablo/Dropbox/trabajo/textos/011-Sleep-Kamitani/figures/from_matlab/figures_rev_cortex/lags/subject' + subject +'/comp' +comp + '/3.png')




