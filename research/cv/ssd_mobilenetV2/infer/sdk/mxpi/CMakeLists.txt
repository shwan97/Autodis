cmake_minimum_required(VERSION 3.5.2)
project(ssd_mobile_net_v2_processor)
add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)
add_definitions(-Dgoogle=mindxsdk_private)

set(PLUGIN_NAME "ssd_mobile_net_v2_processor")
set(TARGET_LIBRARY ${PLUGIN_NAME})
set(ASCEND_DIR $ENV{ASCEND_TOOLKIT}/latest/acllib)
get_filename_component(SDK_INSTALL_DIR $ENV{MX_SDK_HOME} ABSOLUTE)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

include_directories(${SDK_INSTALL_DIR}/include)
include_directories(${SDK_INSTALL_DIR}/opensource/include)
include_directories(${SDK_INSTALL_DIR}/opensource/include/opencv4)
include_directories(${SDK_INSTALL_DIR}/opensource/include/gstreamer-1.0)
include_directories(${SDK_INSTALL_DIR}/opensource/include/glib-2.0)
include_directories(${SDK_INSTALL_DIR}/opensource/lib/glib-2.0/include)
include_directories(../../../)

link_directories(${SDK_INSTALL_DIR}/lib)
link_directories(${SDK_INSTALL_DIR}/opensource/lib/)


add_compile_options(-std=c++11 -fPIC -fstack-protector-all -pie -Wno-deprecated-declarations)
add_compile_options("-DPLUGIN_NAME=${PLUGIN_NAME}")

message("ASCEND_DIR:${ASCEND_DIR}.")
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${ASCEND_DIR}/include)
aux_source_directory(. DIR_LIB_SRCS)

add_library(${TARGET_LIBRARY} SHARED ${DIR_LIB_SRCS})

target_link_libraries(${TARGET_LIBRARY} glib-2.0 gstreamer-1.0 gobject-2.0 gstbase-1.0 gmodule-2.0)
target_link_libraries(${TARGET_LIBRARY} plugintoolkit mxpidatatype mxbase)
target_link_libraries(${TARGET_LIBRARY} -Wl,-z,relro,-z,now,-z,noexecstack)

install(TARGETS ${TARGET_LIBRARY} LIBRARY DESTINATION ${SDK_INSTALL_DIR}/lib/)