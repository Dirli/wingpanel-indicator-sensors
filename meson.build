project (
  'sensors',
  'vala', 'c',
  version: '3.0.0'
)

gnome = import ('gnome')
i18n = import ('i18n')
gettext_name = meson.project_name () + '-indicator'

add_global_arguments ('-DGETTEXT_PACKAGE="@0@"'.format (gettext_name), language:'c')

icons_gresource = gnome.compile_resources (
  'as-resources',
  join_paths ('data', meson.project_name () + '.gresource.xml'),
  source_dir: 'data',
  c_name: 'as'
)

wingpanel_dep = dependency ('wingpanel')

shared_module (
  meson.project_name (),
  'src/Indicator.vala',
  'src/HWMonitor.vala',
  'src/Utils.vala',
  'src/Widgets/MainGrid.vala',
  icons_gresource,
  dependencies: [
      dependency ('glib-2.0'),
      dependency ('gobject-2.0'),
      dependency ('gtk+-3.0'),
      dependency ('gee-0.8'),
      wingpanel_dep
  ],
  install: true,
  install_dir : wingpanel_dep.get_pkgconfig_variable ('indicatorsdir')
)

subdir ('po')
