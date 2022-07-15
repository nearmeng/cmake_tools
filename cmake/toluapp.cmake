
if (MSVC)
	set_property (GLOBAL PROPERTY TOLUAPP_EXE ${CMAKE_CURRENT_SOURCE_DIR}/tools/toluapp/toluapp.exe)
else ()
	set_property (GLOBAL PROPERTY TOLUAPP_EXE ${CMAKE_CURRENT_SOURCE_DIR}/tools/toluapp/toluapp)
endif ()
message("toluapp_exe location1" ${TOLUAPP_EXE})

function (pre_toluapp TARGET_DIR)
	message (----------------------------------------)
	message (pre_toluapp)
	
	get_property(ARG_TOLUAPP_EXE GLOBAL PROPERTY TOLUAPP_EXE)

	file (GLOB_RECURSE FILE_LIST "${TARGET_DIR}/tolua_*.cpp")
	foreach (F ${FILE_LIST})
		file (REMOVE ${F})
		message (removed\ file\ ${F})
	endforeach ()

	file (GLOB_RECURSE FILE_LIST "${TARGET_DIR}/*.pkg")
	foreach (PKG_FILE ${FILE_LIST})
		get_filename_component (FILE_NAME ${PKG_FILE} NAME_WE)
		get_filename_component (FILE_PATH ${PKG_FILE} DIRECTORY)
		execute_process (
			message("toluapp_exe location2" ${TOLUAPP_EXE})
			COMMAND "${ARG_TOLUAPP_EXE}" -s -o tolua_${FILE_NAME}.cpp ${FILE_NAME}.pkg
			WORKING_DIRECTORY ${FILE_PATH}
			RESULT_VARIABLE TOLUAPP_RES)
		if (EXISTS ${FILE_PATH}/tolua_${FILE_NAME}.cpp)
			message (toluappc\ ${FILE_NAME}.pkg)
		else ()
			message (FATAL_ERROR ${FILE_NAME}.pkg\ ${TOLUAPP_RES})
		endif ()
    endforeach ()

	file (GLOB_RECURSE FILE_LIST "${TARGET_DIR}/*.epkg")
	foreach (PKG_FILE ${FILE_LIST})
		get_filename_component (FILE_NAME ${PKG_FILE} NAME_WE)
		get_filename_component (FILE_PATH ${PKG_FILE} DIRECTORY)
		execute_process (
			COMMAND "${ARG_TOLUAPP_EXE}" -s -e -o tolua_${FILE_NAME}.cpp ${FILE_NAME}.epkg
			WORKING_DIRECTORY ${FILE_PATH}
			RESULT_VARIABLE TOLUAPP_RES)
		if (EXISTS ${FILE_PATH}/tolua_${FILE_NAME}.cpp)
			message (toluappce\ ${FILE_NAME}.epkg)
		else ()
			message (FATAL_ERROR ${FILE_NAME}.epkg\ ${TOLUAPP_RES})
		endif ()
    endforeach ()

endfunction ()

function (toluapp TARGET_DIR)
	
	get_property(ARG_TOLUAPP_EXE GLOBAL PROPERTY TOLUAPP_EXE)

	file (GLOB_RECURSE FILE_LIST "${TARGET_DIR}/*.pkg")
	foreach (PKG_FILE ${FILE_LIST})
#		message (${PKG_FILE})
		get_filename_component (FILE_NAME ${PKG_FILE} NAME_WE)
		get_filename_component (FILE_PATH ${PKG_FILE} DIRECTORY)
		get_filename_component (HEADER_FILE ${FILE_PATH}/../${FILE_NAME}.h ABSOLUTE)
		if (NOT EXISTS(${HEADER_FILE}))
			set (HEADER_FILE "")
			file (GLOB_RECURSE HEADER_FILE_LIST "${BASE_DIR}/inc/${FILE_NAME}.h")
			foreach (F ${HEADER_FILE_LIST})
				set (HEADER_FILE ${F})
			endforeach ()
		endif ()
#		message (${HEADER_FILE})
		add_custom_command (
			OUTPUT ${FILE_PATH}/tolua_${FILE_NAME}.cpp 
			MAIN_DEPENDENCY ${PKG_FILE}
			DEPENDS ${HEADER_FILE}
			COMMAND "${ARG_TOLUAPP_EXE}" -s -o tolua_${FILE_NAME}.cpp ${FILE_NAME}.pkg
			WORKING_DIRECTORY ${FILE_PATH}
		)
		if (UNIX)
			add_custom_target (tolua_${FILE_NAME} ALL DEPENDS ${FILE_PATH}/tolua_${FILE_NAME}.cpp)
		endif ()
    endforeach ()

	file (GLOB_RECURSE FILE_LIST "${TARGET_DIR}/*.epkg")
	foreach (PKG_FILE ${FILE_LIST})
#		message (${PKG_FILE})
		get_filename_component (FILE_NAME ${PKG_FILE} NAME_WE)
		get_filename_component (FILE_PATH ${PKG_FILE} DIRECTORY)
		get_filename_component (HEADER_FILE ${FILE_PATH}/../${FILE_NAME}.h ABSOLUTE)
		if (NOT EXISTS(${HEADER_FILE}))
			set (HEADER_FILE "")
			file (GLOB_RECURSE HEADER_FILE_LIST "${BASE_DIR}/inc/${FILE_NAME}.h")
			foreach (F ${HEADER_FILE_LIST})
				set (HEADER_FILE ${F})
			endforeach ()
		endif ()
		add_custom_command (
			OUTPUT ${FILE_PATH}/tolua_${FILE_NAME}.cpp 
			MAIN_DEPENDENCY ${PKG_FILE}
			DEPENDS ${HEADER_FILE}
			COMMAND "${ARG_TOLUAPP_EXE}" -s -e -o tolua_${FILE_NAME}.cpp ${FILE_NAME}.epkg
			WORKING_DIRECTORY ${FILE_PATH}
		)
		if (UNIX)
			add_custom_target (tolua_${FILE_NAME} ALL DEPENDS ${FILE_PATH}/tolua_${FILE_NAME}.cpp)
		endif ()
    endforeach ()

endfunction ()
