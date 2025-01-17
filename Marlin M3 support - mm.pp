+===========================================================================
|
| gCode - Vectric machine output post-processor for vCarve and Aspire
|
+===========================================================================
|
| History
|
| Who       When       What
| ========  ========== =====================================================
| EdwardW   01/13/2020 Initial authoring
|                      Added status messages (M117)
|                      Enabled Arc movements (G2/G3)
|                      Added ending presentation
| EdwardW   02/28/2020
|                      Added G54 (CNC) coordinate support
| EdwardW   10/26/2021
|                      Added router control (M3/M5)
| EdwardW   12/14/2021
|                      Added helical-arc support
|                      Changed to unix line endings
|                      Improved comments
|                      Increased plunge speed when above material
|                      Now uses machine default rapid move speed
|                      Disabled PLUNGE_RATE section to avoid slowdowns
|                      Comments now report carved Z depth, not material Z
| EdwardW   1/22/2022
|                      Minor tweaks and comment updates
|
| Nocturne.op.15 2024/01%08
|                      Added manual toolchange (SKR v.1.2, MPCNC)  
+===========================================================================

POST_NAME = "Marlin w/G54 M3 (mm) (*.gcode)"

FILE_EXTENSION = "gcode"

UNITS = "mm"

+---------------------------------------------------------------------------
|    Configurable items based on your CNC
+---------------------------------------------------------------------------
+ Use 1-100 (%) for spindle speeds instead of true speeds of 10000-27500 (rpm)
SPINDLE_SPEED_RANGE = 1 100 10000 27500

+ Replace all () with <> to avoid gCode interpretation errors
SUBSTITUTE = "([91])[93]"

+ Plunge moves to Plunge (Z2) height are rapid moves
RAPID_PLUNGE_TO_STARTZ = "YES"

+---------------------------------------------------------------------------
|    Line terminating characters
+---------------------------------------------------------------------------
+ Use windows-based line endings \r\n
+ LINE_ENDING = "[13][10]"

+ Use unix-based line endings \n
LINE_ENDING = "[10]"

+---------------------------------------------------------------------------
|    Block numbering
+---------------------------------------------------------------------------
LINE_NUMBER_START     = 0
LINE_NUMBER_INCREMENT = 1
LINE_NUMBER_MAXIMUM = 999999

+===========================================================================
|
|    Formatting for variables
|
+===========================================================================

VAR LINE_NUMBER = [N|A|N|1.0]
VAR SPINDLE_SPEED = [S|A|S|1.0]
VAR CUT_RATE = [FC|C|F|1.0]
VAR PLUNGE_RATE = [FP|C|F|1.0]
VAR X_POSITION = [X|C| X|1.3]
VAR Y_POSITION = [Y|C| Y|1.3]
VAR Z_POSITION = [Z|C| Z|1.3]
VAR ARC_CENTRE_I_INC_POSITION = [I|A| I|1.3]
VAR ARC_CENTRE_J_INC_POSITION = [J|A| J|1.3]
VAR X_HOME_POSITION = [XH|A| X|1.3]
VAR Y_HOME_POSITION = [YH|A| Y|1.3]
VAR Z_HOME_POSITION = [ZH|A| Z|1.3]
+ VAR X_LENGTH = [XLENGTH|A|W:|1.0]
+ VAR Y_LENGTH = [YLENGTH|A|H:|1.0]
+ VAR Z_LENGTH = [ZLENGTH|A|Z:|1.0]
VAR X_LENGTH = [XLENGTH|A||1.0]
VAR Y_LENGTH = [YLENGTH|A||1.0]
VAR Z_LENGTH = [ZLENGTH|A||1.0]
VAR Z_MIN = [ZMIN|A||1.0]
VAR SAFE_Z_HEIGHT = [SAFEZ|A||1.3]
VAR DWELL_TIME = [DWELL|A|S|1.2]


+===========================================================================
|
|    Block definitions for toolpath output
|
+===========================================================================

+---------------------------------------------------------------------------
|  Start of file output
+---------------------------------------------------------------------------
begin HEADER

"; [TP_FILENAME]"
"; Material size: [YLENGTH] x [XLENGTH] x [ZMIN]mm"
"; Tools: [TOOLS_USED]"
"; Paths: [TOOLPATHS_OUTPUT]"
"; Safe Z: [SAFEZ]mm"
"; Generated on [DATE] [TIME] by [PRODUCT]"
"G90"
"G21"
"M117 [YLENGTH]x[XLENGTH]x[ZMIN]mm  Bit #[T]"
"M117 Load [TOOLNAME]"
"M0 Load [TOOLNAME]"
"G54"
"G0 [ZH]"
"G0 [XH][YH]"
"M3 [S]"
";==========================================================================="
";"
";      Path: [TOOLPATH_NAME]"
";      Tool: #[T] : [TOOLNAME]"
";"
";==========================================================================="
"M117 [TOOLPATH_NAME] - Bit #[T]"

+---------------------------------------------------------------------------
|  Rapid (no load) move
+---------------------------------------------------------------------------
begin RAPID_MOVE

"G0 [X][Y][Z]"

+---------------------------------------------------------------------------
|  Carving move
+---------------------------------------------------------------------------
begin FEED_MOVE

"G1 [X][Y][Z] [FC]"

+---------------------------------------------------------------------------
|  Plunging move - Only enable if necessary. Can cause huge slowdowns
+---------------------------------------------------------------------------
begin PLUNGE_MOVE

"G1 [X][Y][Z] [FP]"

+---------------------------------------------------------------------------
|  Clockwise arc move
+---------------------------------------------------------------------------
begin CW_ARC_MOVE

"G2 [X][Y][I][J] [FC]"

+---------------------------------------------------------------------------
|  Counterclockwise arc move
+---------------------------------------------------------------------------
begin CCW_ARC_MOVE

"G3 [X][Y][I][J] [FC]"

+---------------------------------------------------
+  Clockwise helical-arc move
+---------------------------------------------------
begin CW_HELICAL_ARC_MOVE

"G2 [X][Y][Z][I][J] [FC]"

+---------------------------------------------------
+  Counterclockwise helical-arc move
+---------------------------------------------------
begin CCW_HELICAL_ARC_MOVE

"G3 [X][Y][Z][I][J] [FC]"

+---------------------------------------------------------------------------
|  Begin new toolpath
+---------------------------------------------------------------------------
begin NEW_SEGMENT

";==========================================================================="
";"
";      Path: [TOOLPATH_NAME]"
";"
";==========================================================================="
"M117 [TOOLPATH_NAME] - Bit #[T]"

"M3 [S]"

+---------------------------------------------
+  Dwell (momentary pause)
+---------------------------------------------
begin DWELL_MOVE

"G4 [DWELL]"

+---------------------------------------------------------------------------
|  Toolchange (manual)
+---------------------------------------------------------------------------
begin TOOLCHANGE

"M05"
"G01 X0 Y0 Z50"
"M18 Z"
"M117 Load [TOOLNAME]"
"M0 Load [TOOLNAME]"
"G92 Z0"
"M17"
"M3 [S]"

+---------------------------------------------------------------------------
|  End of file output
+---------------------------------------------------------------------------
begin FOOTER

"G0 [ZH]"
"M5"
"G4 S3"
"M117 Returning home"
"G0 [XH][YH]"
"M117 Routing complete."
