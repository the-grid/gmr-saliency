{
  'target_defaults': {
    'default_configuration': 'Release'
  },
  'targets': [
    {
      'target_name': 'saliency',
      'type': 'executable',
      'sources': [
        'saliency.cpp',
        'Saliency/GMRsaliency.cpp',
        'SLIC/SLIC.cpp'
      ],
      'include_dirs': [
        '.'
      ],
      'conditions': [
        ['OS=="mac"', {
          'xcode_settings': {
            'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
            'OTHER_CFLAGS': [
              '-g',
              '-mmacosx-version-min=10.7',
              '-std=c++11',
              '-stdlib=libc++',
              '-O3',
              '-Wall'
            ],
            'OTHER_CPLUSPLUSFLAGS': [
              '-g',
              '-mmacosx-version-min=10.7',
              '-std=c++11',
              '-stdlib=libc++',
              '-O3',
              '-Wall'
            ]
          },
          'libraries': [
            '<!@(pkg-config --libs opencv)'
          ],
          'include_dirs': [
            '<!@(pkg-config opencv --cflags-only-I | sed s/-I//g)'
          ]
        }],
        ['OS=="linux"', {
          'libraries!': [
            '<!@(pkg-config --libs opencv)',
            '-undefined dynamic_lookup'
          ],
          'cflags_cc!': [
            '-fno-exceptions'
          ],
          'cflags': [ '-std=gnu++11', '-fexceptions' ]
        }]
      ]
    }
  ]
}