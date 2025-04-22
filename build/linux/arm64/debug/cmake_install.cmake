# Install script for directory: /home/gentofluck/Рабочий стол/flutter/shots/linux

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/")
  
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots"
         RPATH "$ORIGIN/lib")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle" TYPE EXECUTABLE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/intermediates_do_not_run/flutter_shots")
  if(EXISTS "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots"
         OLD_RPATH "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/hotkey_manager_linux:/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/pasteboard:/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/screen_capturer_linux:/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/screen_retriever_linux:/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/system_tray:/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/window_manager:/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/window_size:/home/gentofluck/Рабочий стол/flutter/shots/linux/flutter/ephemeral:"
         NEW_RPATH "$ORIGIN/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/flutter_shots")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/data/icudtl.dat")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/data" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/linux/flutter/ephemeral/icudtl.dat")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libflutter_linux_gtk.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/linux/flutter/ephemeral/libflutter_linux_gtk.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libhotkey_manager_linux_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/hotkey_manager_linux/libhotkey_manager_linux_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libpasteboard_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/pasteboard/libpasteboard_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libscreen_capturer_linux_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/screen_capturer_linux/libscreen_capturer_linux_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libscreen_retriever_linux_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/screen_retriever_linux/libscreen_retriever_linux_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libsystem_tray_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/system_tray/libsystem_tray_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libwindow_manager_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/window_manager/libwindow_manager_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/libwindow_size_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE FILE FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/window_size/libwindow_size_plugin.so")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib/")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/lib" TYPE DIRECTORY FILES "/home/gentofluck/Рабочий стол/flutter/shots/build/native_assets/linux/")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/data/flutter_assets")
  
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/data/flutter_assets")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/bundle/data" TYPE DIRECTORY FILES "/home/gentofluck/Рабочий стол/flutter/shots/build//flutter_assets")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/flutter/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/runner/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/hotkey_manager_linux/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/pasteboard/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/screen_capturer_linux/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/screen_retriever_linux/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/system_tray/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/window_manager/cmake_install.cmake")
  include("/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/plugins/window_size/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/gentofluck/Рабочий стол/flutter/shots/build/linux/arm64/debug/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
