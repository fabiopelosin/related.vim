
" Plugin and variable setup
"------------------------------------------------------------------------------

if exists("g:ruby_spec_auto_loaded")
  finish
endif
let g:ruby_spec_auto_loaded = 1

runtime! plugin/rubyspec/*.vim

let g:source_pattern = ["lib/*/"]
let g:spec_patterns = ["spec/unit", "spec"]
let g:spec_suffix = "_spec"


" Public interface
"------------------------------------------------------------------------------

" Opens the related file in the current buffer.
"
function! rubyspec#OpenRelated()
  let l:spec_path = rubyspec#Related()
  execute ":e " . l:spec_path
endfunction

" Opens the related file in a vertical split.
"
function! rubyspec#VOpenRelated()
  let l:spec_path = rubyspec#Related()
  execute ":botright vsp " . l:spec_path
endfunction

" Finds the related file of the current buffer.
"
function! rubyspec#Related()
  let l:path = expand("%:p")
  let l:source_path = s:FirstDirMatchingPatterns(l:path, g:source_pattern)
  let l:spec_path = s:FirstDirMatchingPatterns(l:path, g:spec_patterns)

  if s:IsSpec(l:path, g:spec_suffix)
    let l:partial_path = s:ReplaceFilePath(l:path, l:spec_path, l:source_path)
    return s:StripSuffix(l:partial_path, g:spec_suffix)
  else
    let l:partial_path = s:ReplaceFilePath(l:path, l:source_path, l:spec_path)
    return s:AppendSuffix(l:partial_path, g:spec_suffix)
  endif
endfunction


" Public interface
"------------------------------------------------------------------------------

" Example
" s:IsSpec("dir/test.rb", "_spec") #=> false
" s:IsSpec("dir/test_spec.rb", "_spec") #=> true
"
function! s:FirstDirMatchingPatterns(path, patterns)
  for pattern in a:patterns
    let l:candidate = glob(pattern)
    if strlen(l:candidate) && isdirectory(l:candidate)
      return substitute(l:candidate, "\/$", "", "")
    endif
  endfor
endfunction

" Example
" s:IsSpec("dir/test.rb", "_spec") #=> false
" s:IsSpec("dir/test_spec.rb", "_spec") #=> true
"
function! s:IsSpec(path, spec_suffix)
  let l:extension = fnamemodify(a:path, ":e")
  let l:check_pattern = a:spec_suffix . "." . l:extension . "$"
  return a:path =~ l:check_pattern
endfunction

" Example
" s:ReplaceFilePath("/Proj/lib/dir/test.rb", "/Proj/lib", "/Proj/spec")
" #=> "/Proj/lib/spec/test.rb"
"
function! s:ReplaceFilePath(path, from_dir, to_dir)
  return substitute(a:path, a:from_dir, a:to_dir, "")
endfunction

" Example
" s:AppendSuffix("dir/test.rb", "_spec") #=> "dir/test_spec.rb"
"
function! s:AppendSuffix(path, suffix)
  let l:extension = fnamemodify(a:path, ":e")
  let l:pattern = "." . l:extension . "$"
  let l:replacement = a:suffix . "." . l:extension
  return substitute(a:path, l:pattern, l:replacement, "")
endfunction

" Example
" :echo s:AppendSuffix("dir/test_spec.rb", "_spec")
"  => "dir/test.rb"
"
function! s:StripSuffix(path, suffix)
  let l:extension = fnamemodify(a:path, ":e")
  let l:pattern = a:suffix . "." . l:extension . "$"
  let l:replacement = "." . l:extension
  return substitute(a:path, l:pattern, l:replacement, "")
endfunction
