
" Plugin and variable setup
"------------------------------------------------------------------------------

if exists("g:ruby_spec_auto_loaded")
  finish
endif
let g:ruby_spec_auto_loaded = 1

runtime! plugin/rubyspec/*.vim

let g:source_pattern = ["lib/*/", "app"]
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

  let l:filename = expand("%:t")
  let l:dir = expand("%:h")
  let l:root = s:GetGitDir(l:dir)
  let l:source_path = s:FirstDirMatchingPatterns(l:root, g:source_pattern)
  let l:spec_path = s:FirstDirMatchingPatterns(l:root, g:spec_patterns)

  if s:IsSpec(l:filename, g:spec_suffix)
    let l:result_dir = s:ReplaceFilePath(l:dir, l:spec_path, l:source_path)
    let l:result_name = s:StripSuffix(l:filename, g:spec_suffix)
    let l:result = l:result_dir . "/" . l:result_name
    return l:result
  else
    let l:result_dir = s:ReplaceFilePath(l:dir, l:source_path, l:spec_path)
    let l:result_name = s:AppendSuffix(l:filename, g:spec_suffix)
    let l:result = l:result_dir . "/" . l:result_name
    return l:result
  endif
endfunction


" Public interface
"------------------------------------------------------------------------------

" Example
" s:FirstDirMatchingPatterns("dir/lib/name/model.rb", "lib/*/")
" #=> "dir/lib/name"
"
function! s:FirstDirMatchingPatterns(path, patterns)
  for l:pattern in a:patterns
    let l:matches = split(globpath(a:path, l:pattern), '\n')
    if len(l:matches)
      let l:candidate = l:matches[0]
      if isdirectory(l:candidate)
        return substitute(l:candidate, "\/$", "", "")
      endif
    end
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

" Returns the git root of the given path
"
" Example
" s:GetGitDir("dir/lib/file.text")
"  => "dir"
"
function! s:GetGitDir(dir)
  let l:gitdir = system("cd " . a:dir . "; git rev-parse --show-toplevel")
  if matchstr(l:gitdir, '^fatal:.*')
    return dir
  else
    return substitute(gitdir, "\n", "", "")
  endif
endfunction
