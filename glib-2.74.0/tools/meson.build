# Install glib-gettextize executable, if a UNIX-style shell is found
if have_sh
  # These should not contain " quotes around the values
  gettextize_conf = configuration_data()
  gettextize_conf.set('PACKAGE', 'glib')
  gettextize_conf.set('VERSION', meson.project_version())
  gettextize_conf.set('prefix', glib_prefix)
  gettextize_conf.set('datarootdir', glib_datadir)
  gettextize_conf.set('datadir', glib_datadir)
  configure_file(input : 'glib-gettextize.in',
    install_dir : glib_bindir,
    install_tag : 'bin-devel',
    output : 'glib-gettextize',
    configuration : gettextize_conf)
endif

if host_system != 'windows'
  # Install Valgrind suppression file (except on Windows,
  # as Valgrind is currently not supported on Windows)
  install_data('glib.supp',
    install_dir : join_paths(get_option('datadir'), 'glib-2.0', 'valgrind'))
endif
