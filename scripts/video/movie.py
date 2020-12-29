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
t1  = a.loadObject('/home/pablo/disco/utiles/toolboxes/spm12/canonical/'+'single_subj_T1.nii')
w2d = a.createWindow( 'Axial' )
for nod in range(1,51):
	print str(nod)
	im= "%0.3d" % nod
	imagen = a.loadObject('/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro/results/video/images/rim_' + im+'.nii')
	imagen.setPalette("tvalues100-100-100", minVal=-2.5, maxVal=2.5,absoluteMode=True)
	fusion2d=a.fusionObjects([t1,imagen],"Fusion2DMethod")
	a.addObjects(fusion2d, w2d)
	w2d.moveLinkedCursor([90, 107,100 ,96])
	a.execute( 'WindowConfig', windows=[w2d], snapshot='/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro/results/video/images_movie/axial/'+ im +'.png')

w2d = a.createWindow( 'Sagittal' )
for nod in range(1,51):
	print str(nod)
	im= "%0.3d" % nod
	imagen = a.loadObject('/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro/results/video/images/rim_' + im+'.nii')
	imagen.setPalette("tvalues100-100-100", minVal=-2.5, maxVal=2.5,absoluteMode=True)
	fusion2d=a.fusionObjects([t1,imagen],"Fusion2DMethod")
	a.addObjects(fusion2d, w2d)
	w2d.moveLinkedCursor([80, 107,100 ,96])
	a.execute( 'WindowConfig', windows=[w2d], snapshot='/home/pablo/disco2/proyectos/2018-sleep-kamitani-SantiAlvaro/results/video/images_movie/sagital/'+ im +'.png')














