macro(sokol_shader shd slang)
	if(WIN32)
		set(bin_path ${CMAKE_CURRENT_SOURCE_DIR}/bin/win32/sokol-shdc.exe)
	endif()

	set(args "{slang: '${slang}', compiler: '${CMAKE_C_COMPILER_ID}' }")

	add_custom_command(OUTPUT ${shd}.h
		COMMAND ${bin_path} --input ${CMAKE_CURRENT_SOURCE_DIR}/${shd} --output ${CMAKE_CURRENT_BINARY_DIR}/${shd}.h --slang ${slang} --bytecode --format sokol --errfmt ${CMAKE_C_COMPILER_ID}
		COMMENT "Compile shader: ${shd}"
		)
endmacro()