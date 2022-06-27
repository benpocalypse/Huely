huely_sources = [
  'main.vala',
  'window.vala',
  'application.vala',
]

huely_deps = [
  dependency('gtk4'),
]

gnome = import('gnome')

huely_sources += gnome.compile_resources('huely-resources',
  'huely.gresource.xml',
  c_name: 'huely'
)

executable('com.github.benpocalypse.Huely', huely_sources,
  vala_args: '--target-glib=2.50',  dependencies: huely_deps,
  install: true,
)
