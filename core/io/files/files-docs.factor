USING: help.markup help.syntax io io.styles strings
       io.backend io.files.private quotations ;
IN: io.files

ARTICLE: "file-streams" "Reading and writing files"
"File streams:"
{ $subsection <file-reader> }
{ $subsection <file-writer> }
{ $subsection <file-appender> }
"Reading and writing the entire contents of a file; this is only recommended for smaller files:"
{ $subsection file-contents }
{ $subsection set-file-contents }
{ $subsection file-lines }
{ $subsection set-file-lines }
"Utility combinators:"
{ $subsection with-file-reader }
{ $subsection with-file-writer }
{ $subsection with-file-appender } ;

ARTICLE: "pathnames" "Pathname manipulation"
"Pathname manipulation:"
{ $subsection parent-directory }
{ $subsection file-name }
{ $subsection last-path-separator }
{ $subsection append-path }
"Pathnames relative to Factor's temporary files directory:"
{ $subsection temp-directory }
{ $subsection temp-file }
"Pathname presentations:"
{ $subsection pathname }
{ $subsection <pathname> } ;

ARTICLE: "symbolic-links" "Symbolic links"
"Reading and creating links:"
{ $subsection read-link }
{ $subsection make-link }
"Copying links:"
{ $subsection copy-link }
"Not all operating systems support symbolic links."
{ $see-also link-info } ;

ARTICLE: "directories" "Directories"
"Current directory:"
{ $subsection current-directory }
{ $subsection set-current-directory }
{ $subsection with-directory }
"Home directory:"
{ $subsection home }
"Directory listing:"
{ $subsection directory }
{ $subsection directory* }
"Creating directories:"
{ $subsection make-directory }
{ $subsection make-directories } ;

ARTICLE: "file-types" "File Types"
"Platform-independent types:"
{ $subsection +regular-file+ }
{ $subsection +directory+ }
"Platform-specific types:"
{ $subsection +character-device+ }
{ $subsection +block-device+ }
{ $subsection +fifo+ }
{ $subsection +symbolic-link+ }
{ $subsection +socket+ }
{ $subsection +unknown+ } ;

ARTICLE: "fs-meta" "File metadata"
"Querying file-system metadata:"
{ $subsection file-info }
{ $subsection link-info }
{ $subsection exists? }
{ $subsection directory? }
"File types:"
{ $subsection "file-types" } ;

ARTICLE: "delete-move-copy" "Deleting, moving, copying files"
"Operations for deleting and copying files come in two forms:"
{ $list
    { "Words named " { $snippet { $emphasis "operation" } "-file" } " which work on regular files only." }
    { "Words named " { $snippet { $emphasis "operation" } "-tree" } " works on directory trees recursively, and also accepts regular files." }
}
"The operations for moving and copying files come in three flavors:"
{ $list
    { "A word named " { $snippet { $emphasis "operation" } } " which takes a source and destination path." }
    { "A word named " { $snippet { $emphasis "operation" } "-into" } " which takes a source path and destination directory. The destination file will be stored in the destination directory and will have the same file name as the source path." }
    { "A word named " { $snippet { $emphasis "operation" } "s-into" } " which takes a sequence of source paths and destination directory." }
}
"Since both of the above lists apply to copying files, that this means that there are a total of six variations on copying a file."
$nl
"Deleting files:"
{ $subsection delete-file }
{ $subsection delete-directory }
{ $subsection delete-tree }
"Moving files:"
{ $subsection move-file }
{ $subsection move-file-into }
{ $subsection move-files-into }
"Copying files:"
{ $subsection copy-file }
{ $subsection copy-file-into }
{ $subsection copy-files-into }
"Copying directory trees recursively:"
{ $subsection copy-tree }
{ $subsection copy-tree-into }
{ $subsection copy-trees-into }
"On most operating systems, files can only be moved within the same file system. To move files between file systems, use " { $link copy-file } " followed by " { $link delete-file } " on the old name." ;

ARTICLE: "io.files" "Basic file operations"
"The " { $vocab-link "io.files" } " vocabulary provides basic support for working with files."
{ $subsection "pathnames" }
{ $subsection "file-streams" }
{ $subsection "fs-meta" }
{ $subsection "directories" }
{ $subsection "delete-move-copy" } ;

ABOUT: "io.files"

HELP: path-separator?
{ $values { "ch" "a code point" } { "?" "a boolean" } }
{ $description "Tests if the code point is a platform-specific path separator." }
{ $examples
    "On Unix:"
    { $example "USING: io.files prettyprint ;" "CHAR: / path-separator? ." "t" }
} ;

HELP: parent-directory
{ $values { "path" "a pathname string" } { "parent" "a pathname string" } }
{ $description "Strips the last component off a pathname." }
{ $examples { $example "USING: io io.files ;" "\"/etc/passwd\" parent-directory print" "/etc/" } } ;

HELP: file-name
{ $values { "path" "a pathname string" } { "string" string } }
{ $description "Outputs the last component of a pathname string." }
{ $examples
    { $example "USING: io.files prettyprint ;" "\"/usr/bin/gcc\" file-name ." "\"gcc\"" }
    { $example "USING: io.files prettyprint ;" "\"/usr/libexec/awk/\" file-name ." "\"awk\"" }
} ;

! need a $class-description file-info

HELP: file-info
{ $values { "path" "a pathname string" } { "info" file-info } }
{ $description "Queries the file system for metadata. If " { $snippet "path" } " refers to a symbolic link, it is followed. See the article " { $link "file-types" } " for a list of metadata symbols." }
{ $errors "Throws an error if the file does not exist." } ;

HELP: link-info
{ $values { "path" "a pathname string" } { "info" "a file-info tuple" } }
{ $description "Queries the file system for metadata. If path refers to a symbolic link, information about the symbolic link itself is returned. If the file does not exist, an exception is thrown." } ;

{ file-info link-info } related-words

HELP: +regular-file+
{ $description "A regular file. This type exists on all platforms. See " { $link "file-streams" } " for words operating on files." } ;

HELP: +directory+
{ $description "A directory. This type exists on all platforms. See " { $link "directories" } " for words operating on directories." } ;

HELP: +symbolic-link+
{ $description "A symbolic link file.  This type is currently implemented on Unix platforms only. See " { $link "symbolic-links" } " for words operating on symbolic links." } ;

HELP: +character-device+
{ $description "A Unix character device file. This type exists on unix platforms only." } ;

HELP: +block-device+
{ $description "A Unix block device file. This type exists on unix platforms only." } ;

HELP: +fifo+
{ $description "A Unix fifo file. This type exists on unix platforms only." } ;

HELP: +socket+
{ $description "A Unix socket file. This type exists on unix platforms only." } ;

HELP: +unknown+
{ $description "A unknown file type." } ;

HELP: <file-reader>
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" { "stream" "an input stream" } }
    { "stream" "an input stream" } }
{ $description "Outputs an input stream for reading from the specified pathname using the given encoding." }
{ $errors "Throws an error if the file is unreadable." } ;

HELP: <file-writer>
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "stream" "an output stream" } }
{ $description "Outputs an output stream for writing to the specified pathname using the given encoding. The file's length is truncated to zero." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: <file-appender>
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "stream" "an output stream" } }
{ $description "Outputs an output stream for writing to the specified pathname using the given encoding. The stream begins writing at the end of the file." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: with-file-reader
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" "a quotation" } }
{ $description "Opens a file for reading and calls the quotation using " { $link with-stream } "." }
{ $errors "Throws an error if the file is unreadable." } ;

HELP: with-file-writer
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" "a quotation" } }
{ $description "Opens a file for writing using the given encoding and calls the quotation using " { $link with-stream } "." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: with-file-appender
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" "a quotation" } }
{ $description "Opens a file for appending using the given encoding and calls the quotation using " { $link with-stream } "." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: set-file-lines
{ $values { "seq" "an array of strings" } { "path" "a pathname string" } { "encoding" "an encoding descriptor" } }
{ $description "Sets the contents of a file to the strings with the given encoding." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: file-lines
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "seq" "an array of strings" } }
{ $description "Opens the file at the given path using the given encoding, and returns a list of the lines in that file." }
{ $errors "Throws an error if the file cannot be opened for reading." } ;

HELP: set-file-contents
{ $values { "str" "a string" } { "path" "a pathname string" } { "encoding" "an encoding descriptor" } }
{ $description "Sets the contents of a file to a string with the given encoding." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: file-contents
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "str" "a string" } }
{ $description "Opens the file at the given path using the given encoding, and the contents of that file as a string." }
{ $errors "Throws an error if the file cannot be opened for reading." } ;

{ set-file-lines file-lines set-file-contents file-contents } related-words

HELP: cwd
{ $values { "path" "a pathname string" } }
{ $description "Outputs the current working directory of the Factor process." }
{ $errors "Windows CE has no concept of ``current directory'', so this word throws an error there." }
{ $notes "User code should use " { $link with-directory } " or " { $link set-current-directory } " instead." } ;

HELP: cd
{ $values { "path" "a pathname string" } }
{ $description "Changes the current working directory of the Factor process." }
{ $errors "Windows CE has no concept of ``current directory'', so this word throws an error there." }
{ $notes "User code should use " { $link with-directory } " or " { $link set-current-directory } " instead." } ;

{ cd cwd current-directory set-current-directory with-directory } related-words

HELP: current-directory
{ $description "A variable holding the current directory. Words that use the filesystem do so in relation to this variable.  On startup, an init hook sets this word to the directory from which Factor was run." } ;

HELP: with-directory
{ $values { "path" "a pathname string" } { "quot" quotation } }
{ $description "Changes the " { $link current-directory } " variable for the duration of a quotation's execution.  Words that use the file-system should call " { $link normalize-path } " in order to obtain a path relative to the current directory." } ;

HELP: append-path
{ $values { "str1" "a string" } { "str2" "a string" } { "str" "a string" } }
{ $description "Concatenates two pathnames." } ;

HELP: prepend-path
{ $values { "str1" "a string" } { "str2" "a string" } { "str" "a string" } }
{ $description "Concatenates two pathnames." } ;

{ append-path prepend-path } related-words

HELP: absolute-path?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is absolute. Examples of absolute pathnames are " { $snippet "/foo/bar" } " on Unix and " { $snippet "c:\\foo\\bar" } " on Windows." } ;

HELP: windows-absolute-path?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is absolute on Windows. Examples of absolute pathnames on Windows are " { $snippet "c:\\foo\\bar" } " and " { $snippet "\\\\?\\c:\\foo\\bar" } " for absolute Unicode pathnames." } ;

HELP: root-directory?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is a root directory. Examples of root directory pathnames are " { $snippet "/" } " on Unix and " { $snippet "c:\\" } " on Windows." } ;

{ absolute-path? windows-absolute-path? root-directory? } related-words

HELP: exists?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if the file named by " { $snippet "path" } " exists." } ;

HELP: directory?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "path" } " names a directory." } ;

HELP: (directory)
{ $values { "path" "a pathname string" } { "seq" "a sequence of " { $snippet "{ name dir? }" } " pairs" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } "." }
{ $notes "This is a low-level word, and user code should call " { $link directory } " instead." } ;

HELP: directory
{ $values { "path" "a pathname string" } { "seq" "a sequence of " { $snippet "{ name dir? }" } " pairs" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } "." } ;

HELP: directory*
{ $values { "path" "a pathname string" } { "seq" "a sequence of " { $snippet "{ path dir? }" } " pairs" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } "." }
{ $notes "Unlike " { $link directory } ", this word prepends the directory's path to all file names in the list." } ;

! HELP: file-modified
! { $values { "path" "a pathname string" } { "n" "a non-negative integer or " { $link f } } }
! { $description "Outputs a file's last modification time, since midnight January 1, 1970. If the file does not exist, outputs " { $link f } "." } ;

HELP: resource-path
{ $values { "path" "a pathname string" } { "newpath" "a pathname string" } }
{ $description "Resolve a path relative to the Factor source code location. This first checks if the " { $link resource-path } " variable is set to a path, and if not, uses the parent directory of the current image." } ;

HELP: pathname
{ $class-description "Class of pathname presentations. Path name presentations can be created by calling " { $link <pathname> } ". Instances can be passed to " { $link write-object } " to output a clickable pathname." } ;

HELP: normalize-directory
{ $values { "str" "a pathname string" } { "newstr" "a new pathname string" } }
{ $description "Called by the " { $link directory } " word to prepare a pathname before passing it to the " { $link (directory) } " primitive." } ;

HELP: normalize-path
{ $values { "str" "a pathname string" } { "newstr" "a new pathname string" } }
{ $description "Called by words such as " { $link <file-reader> } " and " { $link <file-writer> } " to prepare a pathname before passing it to underlying code." } ;

HELP: <pathname> ( str -- pathname )
{ $values { "str" "a pathname string" } { "pathname" pathname } }
{ $description "Creates a new " { $link pathname } "." } ;

HELP: make-link
{ $values { "target" "a path to the symbolic link's target" } { "symlink" "a path to new symbolic link" } }
{ $description "Creates a symbolic link." } ;

HELP: read-link
{ $values { "symlink" "a path to an existing symbolic link" } { "path" "the path pointed to by the symbolic link" } }
{ $description "Reads the symbolic link and returns its target path." } ;

HELP: copy-link
{ $values { "target" "a path to an existing symlink" } { "symlink" "a path to a new symbolic link" } }
{ $description "Copies a symbolic link without following the link." } ;

{ make-link read-link copy-link } related-words

HELP: home
{ $values { "dir" string } }
{ $description "Outputs the user's home directory." } ;

HELP: delete-file
{ $values { "path" "a pathname string" } }
{ $description "Deletes a file." }
{ $errors "Throws an error if the file could not be deleted." } ;

HELP: make-directory
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory." }
{ $errors "Throws an error if the directory could not be created." } ;

HELP: make-directories
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory and any parent directories which do not yet exist." }
{ $errors "Throws an error if the directories could not be created." } ;

HELP: delete-directory
{ $values { "path" "a pathname string" } }
{ $description "Deletes a directory. The directory must be empty." }
{ $errors "Throws an error if the directory could not be deleted." } ;

HELP: touch-file
{ $values { "path" "a pathname string" } }
{ $description "Updates the modification time of a file or directory. If the file does not exist, creates a new, empty file." }
{ $errors "Throws an error if the file could not be touched." } ;

HELP: delete-tree
{ $values { "path" "a pathname string" } }
{ $description "Deletes a file or directory, recursing into subdirectories." }
{ $errors "Throws an error if the deletion fails." }
{ $warning "Misuse of this word can lead to catastrophic data loss." } ;

HELP: move-file
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Moves or renames a file." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." } ;

HELP: move-file-into
{ $values { "from" "a pathname string" } { "to" "a directory pathname string" } }
{ $description "Moves a file to another directory without renaming it." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." } ;

HELP: move-files-into
{ $values { "files" "a sequence of pathname strings" } { "to" "a directory pathname string" } }
{ $description "Moves a set of files to another directory." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." } ;

HELP: copy-file
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Copies a file." }
{ $notes "This operation attempts to preserve the original file's attributes, however not all attributes may be preserved." }
{ $errors "Throws an error if the file does not exist or if the copy operation fails." } ;

HELP: copy-file-into
{ $values { "from" "a pathname string" } { "to" "a directory pathname string" } }
{ $description "Copies a file to another directory." }
{ $errors "Throws an error if the file does not exist or if the copy operation fails." } ;

HELP: copy-files-into
{ $values { "files" "a sequence of pathname strings" } { "to" "a directory pathname string" } }
{ $description "Copies a set of files to another directory." }
{ $errors "Throws an error if the file does not exist or if the copy operation fails." } ;

HELP: copy-tree
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Copies a directory tree recursively." }
{ $notes "This operation attempts to preserve original file attributes, however not all attributes may be preserved." }
{ $errors "Throws an error if the copy operation fails." } ;

HELP: copy-tree-into
{ $values { "from" "a pathname string" } { "to" "a directory pathname string" } }
{ $description "Copies a directory tree to another directory, recursively." }
{ $errors "Throws an error if the copy operation fails." } ;

HELP: copy-trees-into
{ $values { "files" "a sequence of pathname strings" } { "to" "a directory pathname string" } }
{ $description "Copies a set of directory trees to another directory, recursively." }
{ $errors "Throws an error if the copy operation fails." } ;


