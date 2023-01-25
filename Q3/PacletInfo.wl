(* Paclet Info File *)
(* $Date: 2023-01-25 09:01:29+09 $ *)
(* $Revision: 2.120 $ *)

Paclet[
  "Name" -> "Q3",
  "Version" -> "2.9.4",
  "WolframVersion" -> "12.1+",
  "Updating" -> Automatic,
  "Loading" -> "Startup",
  "Extensions" -> {
    { "Kernel",
      "Root" -> "Kernel",
      "Context" -> { "Q3`" },
      (* Context specifies the package context or list of contexts.
         The list is also used by FindFile.
         The list also causes documentation links to be added to usage
         messages when documentation is present. *)
      "Symbols" -> { "Let", "Q3Info", "Q3Update", "Q3CheckUpdate" }
      (* Symbols supplies a set of symbols that the paclet provides. If the
         Loading is set to Automatic , autoloading will be set up for everyone
         of these symbols. *)
     },
    { "Documentation",
      "Language" -> "English",
      "MainPage" -> "Tutorials/Q3QuickStart" },
    { "FrontEnd",
      "Prepend" -> True }
    (* Enables subdirectories within the FrontEnd to be handled,
       e.g. FrontEnd/Palettes, FrontEnd/StyleSheets, FrontEnd/SystemResources,
       FrontEnd/TextResources. These items will be recognized by the Front
       End, e.g. palettes will show up in the Palettes menu. *)
   },
  "Description" -> "Mathematica application to help study quantum information processing, quantum many-body systems, and quantum spin systems",
  "Creator" -> "Mahn-Soo Choi (Korea University)",
  "URL" -> "https://github.com/quantum-mob/Q3",
  "Category" -> { "Physics", "Quantum Physics" },
  "Keywords" -> { "quantum information", "quantum computation",
    "quantum many-body systems", "quantum spins" },
  "Support" -> "quantum.mob21@gmail.com"
 ]
