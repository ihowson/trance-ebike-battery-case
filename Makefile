# sorry, you can fix this
OPENSCAD := /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

all: battcase.scad
	${OPENSCAD} -o side.dxf -D 'PART="side"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o side.svg -D 'PART="side"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o top.dxf -D 'PART="top"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o top.svg -D 'PART="top"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o bottom.dxf -D 'PART="bottom"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o bottom.svg -D 'PART="bottom"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o shock.dxf -D 'PART="shock"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o shock.svg -D 'PART="shock"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o rear.dxf -D 'PART="rear"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o rear.svg -D 'PART="rear"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o cap.dxf -D 'PART="cap"' -D 'DISPLAY=0' battcase.scad
	${OPENSCAD} -o cap.svg -D 'PART="cap"' -D 'DISPLAY=0' battcase.scad
