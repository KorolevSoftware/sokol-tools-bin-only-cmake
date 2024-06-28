function(sokol_shader shd slang)
	if(WIN32)
		set(bin_path ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/bin/win32/sokol-shdc.exe)
	endif()
	add_custom_command(OUTPUT ${shd}.h
		COMMAND ${bin_path} --input ${CMAKE_CURRENT_SOURCE_DIR}/${shd} --output ${CMAKE_CURRENT_BINARY_DIR}/compile_shaders/${shd}.h --slang ${slang} --bytecode --format sokol
		COMMENT "Compile shader: ${shd}"
		)
endfunction()
