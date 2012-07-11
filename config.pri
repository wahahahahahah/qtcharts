##################### LIB #################################################

LIBRARY_NAME = QtCommercialChart
CONFIG(debug, debug|release) {
    mac: LIBRARY_NAME = $$join(LIBRARY_NAME,,,_debug)
    win32: LIBRARY_NAME = $$join(LIBRARY_NAME,,,d)
}

LIBS += -l$$LIBRARY_NAME

# This will undefine Q_DECL_EXPORT/Q_DECL_IMPORT at qchartglobal.h
# They should not be used for staticlib builds.
staticlib:DEFINES+=QTCOMMERCIALCHART_STATICLIB

##################### SHADOW CONFIG #################################################

!contains($${PWD}, $${OUT_PWD}){
    search = "$$PWD:::"
    temp = $$split(search,"/")    
    temp = $$last(temp)
    path = $$replace(search,$$temp,'')
    temp = $$split(OUT_PWD,$$path)
    temp = $$split(temp,'/')
    temp = $$first(temp)
    path = "$${path}$${temp}"
    SHADOW=$$path   
}else{
    SHADOW=$$PWD
    CONFIG-=development_build 
}

##################### BUILD PATHS ##################################################

CHART_BUILD_PUBLIC_HEADER_DIR = $$SHADOW/include
CHART_BUILD_PRIVATE_HEADER_DIR = $$CHART_BUILD_PUBLIC_HEADER_DIR/private
CHART_BUILD_LIB_DIR = $$SHADOW/lib
CHART_BUILD_DIR = $$SHADOW/build
CHART_BUILD_BIN_DIR = $$SHADOW/bin
CHART_BUILD_PLUGIN_DIR = $$CHART_BUILD_BIN_DIR/QtCommercial/Chart
CHART_BUILD_DOC_DIR = $$SHADOW/doc

# Use own folders for debug and release builds

CONFIG(debug, debug|release):CHART_BUILD_DIR = $$join(CHART_BUILD_DIR,,,/debug)
CONFIG(release, debug|release): CHART_BUILD_DIR = $$join(CHART_BUILD_DIR,,,/release)


win32:{
    CHART_BUILD_PUBLIC_HEADER_DIR = $$replace(CHART_BUILD_PUBLIC_HEADER_DIR, "/","\\")
    CHART_BUILD_PRIVATE_HEADER_DIR = $$replace(CHART_BUILD_PRIVATE_HEADER_DIR, "/","\\")
    CHART_BUILD_BUILD_DIR = $$replace(CHART_BUILD_BUILD_DIR, "/","\\")
    CHART_BUILD_BIN_DIR = $$replace(CHART_BUILD_BIN_DIR, "/","\\")
    CHART_BUILD_PLUGIN_DIR = $$replace(CHART_BUILD_PLUGIN_DIR, "/","\\")
    CHART_BUILD_DOC_DIR = $$replace(CHART_BUILD_DOC_DIR, "/","\\")
    CHART_BUILD_LIB_DIR = $$replace(CHART_BUILD_LIB_DIR, "/","\\")
}

mac: {
    # TODO: The following qmake flags are a work-around to make QtCommercial Charts compile on
    # QtCommercial 4.8. On the other hand Charts builds successfully with Qt open source 4.8
    # without these definitions, so this is probably a configuration issue on QtCommercial 4.8;
    # it should probably define the minimum OSX version to be 10.5...
    QMAKE_CXXFLAGS *= -mmacosx-version-min=10.5
    QMAKE_LFLAGS *= -mmacosx-version-min=10.5
}

##################### INCLUDES ############################################################


INCLUDEPATH += $$CHART_BUILD_PUBLIC_HEADER_DIR

!win32: {
    LIBS += -L $$CHART_BUILD_LIB_DIR -Wl,-rpath,$$CHART_BUILD_LIB_DIR
} else {
    win32-msvc*: {
        # hack fix for error:
        #   "LINK : fatal error LNK1146: no argument specified with option '/LIBPATH:'"
        QMAKE_LIBDIR += $$CHART_BUILD_LIB_DIR
    } else {
        LIBS += -L $$CHART_BUILD_LIB_DIR
    }
}

##################### DEVELOPMENT BUILD ###################################################

development_build: {
    DEFINES+=DEVELOPMENT_BUILD
    CONFIG+=debug_and_release
    CONFIG+=build_all
}

##################### UNIT TESTS ##############################################################

CONFIG(debug, debug|release) {
    CONFIG+=test_private
    DEFINES+=BUILD_PRIVATE_UNIT_TESTS
}

#################### COVERAGE #################################################################
coverage: CONFIG += debug
