" Remove # from the list of characters that vim considers part of a single
" word.  Advantage is that w e b etc stop at # when moving over an autoload
" function.  Disadvantage is that tag jumping and completion will no longer
" see 'foo#bar' as a single entity to jump to or insert.  I don't use those
" features often enough to justify how often I get annoyed by movements moving
" to the wrong spot.
setlocal isk-=#
