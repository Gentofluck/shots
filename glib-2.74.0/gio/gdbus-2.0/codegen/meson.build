gdbus_codegen_files = [
  '__init__.py',
  'codegen.py',
  'codegen_main.py',
  'codegen_docbook.py',
  'codegen_rst.py',
  'dbustypes.py',
  'parser.py',
  'utils.py',
]

gdbus_codegen_conf = configuration_data()
gdbus_codegen_conf.set('VERSION', glib_version)
gdbus_codegen_conf.set('MAJOR_VERSION', major_version)
gdbus_codegen_conf.set('MINOR_VERSION', minor_version)
gdbus_codegen_conf.set('PYTHON', python_name)
gdbus_codegen_conf.set('DATADIR', glib_datadir)

# Install gdbus-codegen executable
gdbus_codegen = configure_file(input : 'gdbus-codegen.in',
  output : 'gdbus-codegen',
  install_dir : get_option('bindir'),
  install_tag : 'bin-devel',
  configuration : gdbus_codegen_conf
)
  # Provide tools for others when we're a subproject and they use the Meson GNOME module
meson.override_find_program('gdbus-codegen', gdbus_codegen)

codegen_dir = join_paths(glib_datadir, 'glib-2.0', 'codegen')

gdbus_codegen_built_files = []
gdbus_codegen_built_files += configure_file(input : 'config.py.in',
                                            output : 'config.py',
                                            install_dir : codegen_dir,
                                            configuration : gdbus_codegen_conf)

foreach f : gdbus_codegen_files
  # Copy these into the builddir so that gdbus-codegen can be used uninstalled
  # and then install it too so that it can be used after installation
  gdbus_codegen_built_files += configure_file(input : f, output : f,
                                              install_dir : codegen_dir,
                                              copy : true)
endforeach
