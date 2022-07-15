if (MSVC)
	set_property (GLOBAL PROPERTY PROTOC_EXE ${CMAKE_CURRENT_SOURCE_DIR}/tools/protoc/protoc.exe)
	set_property (GLOBAL PROPERTY PROTOC_ERR msvs)
else ()
	set_property (GLOBAL PROPERTY PROTOC_EXE ${CMAKE_CURRENT_SOURCE_DIR}/tools/protoc/protoc)
	set_property (GLOBAL PROPERTY PROTOC_ERR gcc)
endif ()

function (preprocess_proto file_path)
	message (----------------------------------------)
	message (preprocess_proto)

	file (GLOB_RECURSE PROTO_FILES "${BASE_DIR}/${file_path}/*.proto")
	
	get_property(ARG_PROTOC_EXE GLOBAL PROPERTY PROTOC_EXE)
	get_property(ARG_PROTOC_ERR GLOBAL PROPERTY PROTOC_ERR)
	get_property(ARG_PROTO_PATH GLOBAL PROPERTY PROTO_INC_PATH)

	foreach (PROTO_FILE ${PROTO_FILES})
		get_filename_component (FILE_NAME ${PROTO_FILE} NAME_WE)
		get_filename_component (FILE_PATH ${PROTO_FILE} DIRECTORY)

		file (REMOVE ${FILE_PATH}/${FILE_NAME}.cc)
		message ("removed file ${FILE_PATH}/${FILE_NAME}.cc")
		file (REMOVE ${FILE_PATH}/${FILE_NAME}.h)
		message ("removed file ${FILE_PATH}/${FILE_NAME}.h")

		execute_process (
			COMMAND "${ARG_PROTOC_EXE}" ${FILE_NAME}.proto --proto_path=${ARG_PROTO_PATH} --proto_path=./ --error_format=${ARG_PROTOC_ERR} --cpp_out=.
			WORKING_DIRECTORY ${FILE_PATH}
			RESULT_VARIABLE PROTO_RES)
		if (EXISTS ${FILE_PATH}/${FILE_NAME}.pb.cc)
			message (protoc\ ${FILE_NAME}.proto)
			LIST(APPEND SRC_FILES ${FILE_PATH}/${FILE_NAME}.pb.cc)
			LIST(APPEND SRC_FILES ${FILE_PATH}/${FILE_NAME}.pb.h)
		else ()
			message (FATAL_ERROR ${FILE_NAME}.proto\ ${PROTO_RES})
		endif ()
	endforeach ()
endfunction ()

function (process_proto file_path)

	message("server proto files ${SERVER_PROTO_FILES}")

	file (GLOB_RECURSE PROTO_FILES "${BASE_DIR}/${ARGV0}/*.proto")
	LIST(APPEND PROTO_FILES ${SERVER_PROTO_FILES})
	
	get_property(ARG_PROTOC_EXE GLOBAL PROPERTY PROTOC_EXE)
	get_property(ARG_PROTOC_ERR GLOBAL PROPERTY PROTOC_ERR)
	get_property(ARG_PROTO_PATH GLOBAL PROPERTY PROTO_INC_PATH)

	foreach (PROTO_FILE ${PROTO_FILES})
		get_filename_component (FILE_NAME ${PROTO_FILE} NAME_WE)
		get_filename_component (FILE_PATH ${PROTO_FILE} DIRECTORY)
		add_custom_command (
			OUTPUT ${FILE_PATH}/${FILE_NAME}.pb.cc 
			OUTPUT ${FILE_PATH}/${FILE_NAME}.pb.h
			MAIN_DEPENDENCY ${PROTO_FILE}
			COMMAND "${ARG_PROTOC_EXE}" ${FILE_NAME}.proto --proto_path=${PROTO_INC_PATH} --proto_path=./ --error_format=${ARG_PROTOC_ERR} --cpp_out=.
			WORKING_DIRECTORY ${FILE_PATH}
		)
		if (UNIX)
			add_custom_target (proto_${FILE_NAME} ALL DEPENDS ${FILE_PATH}/${FILE_NAME}.pb.cc)
		endif ()
    endforeach ()
endfunction ()
