Turing.machines = {}

Turing.machines.alternatingOnesAndZeros = [
   ['a', 'none',        'P0', 'a'],
   [ '',    '0',  'R, R, P1', 'a'],
   [ '',    '1',  'R, R, P0', 'a']
]

Turing.machines.oneFourth = [
   ['a', 'none', 'P0, R', 'b'],
   ['b', 'none',     'R', 'c'],
   ['c', 'none', 'P1, R', 'd'],
   ['d', 'none',     'R', 'e'],
   ['e', 'none', 'P0, R', 'd']
]

Turing.machines.sequencesOfOnes = [
   ['a',  'any', 'P@, R, P@, R, P0, R, R, P0, L, L', 'b'],
   ['b',    '1',                   'R, Px, L, L, L', 'b'],
   [ '',    '0',                                 '', 'c'],
   ['c',    'any',                           'R, R', 'c'],
   [ '', 'none',                            'P1, L', 'd'],
   ['d',    'x',                             'E, R', 'c'],
   [ '',    '@',                                'R', 'e'],
   [ '', 'none',                             'L, L', 'd'],
   ['e',  'any',                             'R, R', 'e'],
   [ '', 'none',                         'P0, L, L', 'b'],
]   