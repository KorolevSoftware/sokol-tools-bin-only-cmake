## Nim build helper for invoking the bundled sokol-shdc executable.

import std/[os, osproc, sequtils, strformat, strutils]

type
  ShaderOptions* = object
    ## Root directory containing the bin/ directory from sokol-tools-bin.
    shdcDir*: string
    input*: string
    output*: string
    slang*: string
    defines*: string
    module*: string
    reflection*: bool
    debuggable*: bool
    bytecode*: bool
    genver*: int

proc findShdc*(shdcDir = "."): string =
  ## Return the sokol-shdc executable for the host running the Nim build.
  let binDir = absolutePath(shdcDir) / "bin"

  when hostOS == "windows":
    when hostCPU == "amd64" or hostCPU == "x86_64":
      result = binDir / "win32" / "sokol-shdc.exe"
    elif hostCPU == "arm64" or hostCPU == "aarch64":
      raise newException(
        OSError,
        "Windows ARM64 is not supported by sokol-shdc"
      )
    elif hostCPU == "i386" or hostCPU == "i686" or hostCPU == "x86":
      raise newException(
        OSError,
        "32-bit Windows is not supported by sokol-shdc"
      )
    else:
      raise newException(
        OSError,
        &"Unsupported Windows host architecture: {hostCPU}"
      )
  elif hostOS == "macosx":
    when hostCPU == "arm64" or hostCPU == "aarch64":
      result = binDir / "osx_arm64" / "sokol-shdc"
    elif hostCPU == "amd64" or hostCPU == "x86_64":
      result = binDir / "osx" / "sokol-shdc"
    else:
      raise newException(
        OSError,
        &"Unsupported macOS host architecture: {hostCPU}"
      )
  elif hostOS == "linux":
    when hostCPU == "arm64" or hostCPU == "aarch64":
      result = binDir / "linux_arm64" / "sokol-shdc"
    elif hostCPU == "amd64" or hostCPU == "x86_64":
      result = binDir / "linux" / "sokol-shdc"
    else:
      raise newException(
        OSError,
        &"Unsupported Linux host architecture: {hostCPU}"
      )
  else:
    raise newException(
      OSError,
      &"Unsupported host platform: {hostOS}-{hostCPU}"
    )

  if not fileExists(result):
    raise newException(OSError, &"sokol-shdc binary not found: {result}")

proc compile*(options: ShaderOptions) =
  ## Generate one Nim shader module using the sokol_nim output format.
  if options.input.len == 0:
    raise newException(ValueError, "Shader input path is empty")
  if options.output.len == 0:
    raise newException(ValueError, "Shader output path is empty")
  if options.slang.len == 0:
    raise newException(ValueError, "Shader language list is empty")
  if not fileExists(options.input):
    raise newException(OSError, &"Shader input not found: {options.input}")

  let outputDir = parentDir(options.output)
  if outputDir.len > 0:
    createDir(outputDir)

  var args = @[
    "--input", options.input,
    "--output", options.output,
    "--slang", options.slang,
    "--format", "sokol_nim"
  ]

  let version = if options.genver == 0: 5 else: options.genver
  args.add("--genver")
  args.add($version)

  if options.defines.len > 0:
    args.add("--defines")
    args.add(options.defines)
  if options.module.len > 0:
    args.add("--module")
    args.add(options.module)
  if options.reflection:
    args.add("--reflection")
  if options.bytecode and not options.debuggable:
    args.add("--bytecode")

  let command = quoteShell(findShdc(options.shdcDir)) & " " &
    args.mapIt(quoteShell(it)).join(" ")
  let (output, exitCode) = execCmdEx(command)
  if output.len > 0:
    stdout.write(output)
  if exitCode != 0:
    raise newException(
      OSError,
      &"sokol-shdc failed with exit code {exitCode}"
    )

proc compileMany*(shaders: openArray[ShaderOptions]) =
  ## Generate multiple Nim shader modules.
  for shader in shaders:
    compile(shader)
