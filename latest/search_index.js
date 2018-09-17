var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Keys.False",
    "page": "Home",
    "title": "Keys.False",
    "category": "type",
    "text": "a TypedBool\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.Key",
    "page": "Home",
    "title": "Keys.Key",
    "category": "type",
    "text": "struct Key{K}\n\nA typed key. See @__str for an easy way to create keys. Use to create Keyed values.\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.Keyed",
    "page": "Home",
    "title": "Keys.Keyed",
    "category": "type",
    "text": "struct Keyed{K, V}\n\nan alias for a Key-value pair. a tuple of Keyed values is aliased as a KeyedTuple.\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.KeyedTuple",
    "page": "Home",
    "title": "Keys.KeyedTuple",
    "category": "type",
    "text": "const KeyedTuple\n\nA tuple with only Keyed values. You can index them with Keys or access them with dots. Duplicated keys are allowed; will return the first match.\n\njulia> using Keys\n\njulia> keyed_tuple = (_\"a\" => 1, _\"b\" => 2)\n(.a => 1, .b => 2)\n\njulia> keyed_tuple.b\n2\n\njulia> keyed_tuple[(_\"a\", _\"b\")]\n(.a => 1, .b => 2)\n\njulia> keyed_tuple.c\nERROR: Key .c not found\n[...]\n\njulia> haskey(keyed_tuple, _\"b\")\nTrue()\n\njulia> merge(keyed_tuple, (_\"a\" => 4, _\"c\" => 3))\n(.b => 2, .a => 4, .c => 3)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.True",
    "page": "Home",
    "title": "Keys.True",
    "category": "type",
    "text": "a TypedBool\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.TypedBool",
    "page": "Home",
    "title": "Keys.TypedBool",
    "category": "type",
    "text": "abstract TypedBool\n\ntyped bools, True and False, can guarantee type stability in cases where constant propogation is not working for Bools.\n\njulia> using Keys\n\njulia> Bool(False())\nfalse\n\njulia> Bool(True())\ntrue\n\njulia> TypedBool(false)\nFalse()\n\njulia> TypedBool(true)\nTrue()\n\njulia> True() & True() & False()\nFalse()\n\njulia> False() & False() & True()\nFalse()\n\njulia> True() | True() | False()\nTrue()\n\njulia> False() | False() | True()\nTrue()\n\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.delete-Tuple{Tuple{Pair{Key{K},V} where V where K,Vararg{Pair{Key{K},V} where V where K,N} where N},Vararg{Key,N} where N}",
    "page": "Home",
    "title": "Keys.delete",
    "category": "method",
    "text": "delete(keyed_tuple::KeyedTuple, keys::Key...)\n\ndelete all Keyed values matching Keys in a KeyedTuple.\n\njulia> using Keys\n\njulia> delete((_\"a\" => 1, _\"b\" => 2), _\"a\")\n(.b => 2,)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.fill_tuple-Tuple{Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A},Any}",
    "page": "Home",
    "title": "Keys.fill_tuple",
    "category": "method",
    "text": "julia> using Keys\n\njulia> fill_tuple((1, \'a\', 1.0), \"a\")\n(\"a\", \"a\", \"a\")\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.filter_unrolled-Tuple{Any,Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A}}",
    "page": "Home",
    "title": "Keys.filter_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> filter_unrolled(identity, (True(), False()))\n(True(),)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.find_unrolled-Tuple{Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A},Integer}",
    "page": "Home",
    "title": "Keys.find_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> find_unrolled((true, false, true))\n(1, 3)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.flatten_unrolled-Tuple{Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A}}",
    "page": "Home",
    "title": "Keys.flatten_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> flatten_unrolled(((1, 2.0), (\"c\", 4//4)))\n(1, 2.0, \"c\", 1//1)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.getindex_unrolled-Tuple{Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A},Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A}}",
    "page": "Home",
    "title": "Keys.getindex_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> getindex_unrolled((1, \"a\", 1.0), (true, false, true))\n(1, 1.0)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.key-Union{Tuple{Pair{Key{K},V} where V}, Tuple{K}} where K",
    "page": "Home",
    "title": "Keys.key",
    "category": "method",
    "text": "key(keyed::Keyed)\n\nget the key of a Keyed value.\n\njulia> using Keys\n\njulia> key.((_\"a\" => 1, _\"b\" => 2))\n(.a, .b)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.map_values-Tuple{Any,Tuple{Pair{Key{K},V} where V where K,Vararg{Pair{Key{K},V} where V where K,N} where N}}",
    "page": "Home",
    "title": "Keys.map_values",
    "category": "method",
    "text": "map_values(f, keyed_tuple::KeyedTuple)\n\nmap f over the values of a KeyedTuple.\n\njulia> using Keys\n\njulia> map_values(x -> x + 1, (_\"a\" => 1, _\"b\" => 2))\n(.a => 2, .b => 3)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.not-Tuple{False}",
    "page": "Home",
    "title": "Keys.not",
    "category": "method",
    "text": "not(x)\n\nTypedBool aware version of !.\n\njulia> using Keys\n\njulia> not(True())\nFalse()\n\njulia> not(False())\nTrue()\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.product_unrolled-Tuple{Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A},Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A}}",
    "page": "Home",
    "title": "Keys.product_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> product_unrolled((1, 2.0), (\"c\", 4//4))\n((1, \"c\"), (2.0, \"c\"), (1, 1//1), (2.0, 1//1))\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.push-Tuple{Tuple{Pair{Key{K},V} where V where K,Vararg{Pair{Key{K},V} where V where K,N} where N},Vararg{Pair{Key{K},V} where V where K,N} where N}",
    "page": "Home",
    "title": "Keys.push",
    "category": "method",
    "text": "push(keyed_tuple::KeyedTuple, pairs::Keyed...)\n\npush the Keyed values in pairs into the KeyedTuple, replacing common Keys.\n\njulia> using Keys\n\njulia> push((_\"a\" => 1, _\"b\" => 2), _\"b\" => 4, _\"c\" => 3)\n(.a => 1, .b => 4, .c => 3)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.reduce_unrolled-Tuple{Any,Any,Union{Tuple{}, Tuple{A} where A, Tuple{A,B} where B where A, Tuple{A,B,C} where C where B where A, Tuple{A,B,C,D} where D where C where B where A, Tuple{A,B,C,D,E} where E where D where C where B where A, Tuple{A,B,C,D,E,F} where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G} where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H} where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I} where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J} where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K} where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L} where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M} where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N} where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O} where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A, Tuple{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P} where P where O where N where M where L where K where J where I where H where G where F where E where D where C where B where A}}",
    "page": "Home",
    "title": "Keys.reduce_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> reduce_unrolled(&, (true, false, true))\nfalse\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.rename-Tuple{Tuple{Pair{Key{K},V} where V where K,Vararg{Pair{Key{K},V} where V where K,N} where N},Vararg{Pair{T1,T2} where T2<:Key where T1<:Key,N} where N}",
    "page": "Home",
    "title": "Keys.rename",
    "category": "method",
    "text": "rename(keyed_tuple::KeyedTuple, pairs_of_keys::PairOfKeys...)\n\nfor each pair of Keys, where the first key matches in KeyedTuple, it will be replaced by the second.\n\njulia> using Keys\n\njulia> rename((_\"a\" => 1, _\"b\" => 2), _\"c\" => _\"a\")\n(.c => 1, .b => 2)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.same_type-Union{Tuple{T}, Tuple{T,T}} where T",
    "page": "Home",
    "title": "Keys.same_type",
    "category": "method",
    "text": "same_type(a, b)\n\nCheck whether a and b are the same type; return a TypedBool.\n\njulia> using Keys\n\njulia> same_type(1, 2)\nTrue()\n\njulia> same_type(1, 2.0)\nFalse()\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.setindex_unrolled-Tuple{Tuple{},Tuple{},Tuple{}}",
    "page": "Home",
    "title": "Keys.setindex_unrolled",
    "category": "method",
    "text": "julia> using Keys\n\njulia> setindex_unrolled(\n            (1, \"a\", 1.0),\n            (\'a\', 1//1),\n            (True(), False(), True())\n        )\n(\'a\', \"a\", 1//1)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.value-Tuple{Pair{Key{K},V} where V where K}",
    "page": "Home",
    "title": "Keys.value",
    "category": "method",
    "text": "value(key::Keyed)\n\nget the value of a Keyed value.\n\njulia> using Keys\n\njulia> value.((_\"a\" => 1, _\"b\" => 2))\n(1, 2)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.@_-Tuple{Expr}",
    "page": "Home",
    "title": "Keys.@_",
    "category": "macro",
    "text": "macro _(body::Expr)\n\nAnother syntax for anonymous functions. The arguments are inside the body; the first arguments is _, the second argument is __, etc.\n\njulia> using Keys\n\njulia> 1 |> (@_ _ + 1)\n2\n\njulia> map((@_ __ - _), (1, 2), (2, 1))\n(1, -1)\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.@__str-Tuple{String}",
    "page": "Home",
    "title": "Keys.@__str",
    "category": "macro",
    "text": "@__str\n\nmake a key\n\njulia> using Keys\n\njulia> _\"a\"\n.a\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.@query-Tuple{Any}",
    "page": "Home",
    "title": "Keys.@query",
    "category": "macro",
    "text": "macro query(body::Expr)\n\nPrepare your code for querying. If body is a chain head_ |> tail_, recur on head. If tail is a function call, and the function ends with a number (the parity), anonymize and quote arguments past that parity. Either way, anonymize the whole tail, then call it on head.\n\njulia> using Keys\n\njulia> call(source1, source2, anonymous, quoted) = anonymous(source1, source2);\n\njulia> @query 1 |> (_ - 2) |> abs(_) |> call2(_, 2, _ + __)\n3\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.if_else-Tuple{Bool,Any,Any}",
    "page": "Home",
    "title": "Keys.if_else",
    "category": "method",
    "text": "if_else(switch, new, old)\n\nTypedBool aware version of ifelse.\n\njulia> using Keys\n\njulia> if_else(true, 1, 0)\n1\n\njulia> if_else(True(), 1, 0)\n1\n\njulia> if_else(False(), 1, 0)\n0\n\n\n\n\n\n"
},

{
    "location": "index.html#Keys.jl-1",
    "page": "Home",
    "title": "Keys.jl",
    "category": "section",
    "text": "Modules = [Keys]"
},

]}
