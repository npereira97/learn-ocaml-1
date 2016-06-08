(* This file is part of Learn-OCaml.
 *
 * Copyright (C) 2016 OCamlPro.
 *
 * Learn-OCaml is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * Learn-OCaml is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *)

let get_grade ?callback exo solution =
  let path = "/grading_cmis" in
  let root =
    OCamlRes.Res.merge
      Embedded_cmis.root
      Embedded_grading_cmis.root in
  Sys_js.register_autoload ~path
    (fun (prefix, suffix) ->
       match OCamlRes.Res.find (OCamlRes.Path.of_string suffix) root with
       | cmi ->
           Js.Unsafe.set cmi (Js.string "t") 9 ; (* XXX hack *)
           Some cmi
       | exception Not_found -> None) ;
  Config.load_path := [ path ] ;
  Toploop_jsoo.initialize () ;
  let divert name chan cb =
    let redirection = Toploop_jsoo.redirect_channel name chan cb in
    fun () -> Toploop_jsoo.stop_channel_redirection redirection in
  Grading.get_grade ?callback ~divert exo solution

open Grader_jsoo_messages

let () =
  Worker.set_onmessage @@ fun (json : Browser_json.Repr.value) ->
  let { exercise ; solution } =
    Browser_json.Json_encoding.destruct to_worker_enc json in
  let callback msg =
    let msg = Callback msg in
    let json = Browser_json.Json_encoding.construct from_worker_enc msg in
    Worker.post_message json in
  let ans =
    try
      let report, stdout, stderr, outcomes =
        get_grade ~callback exercise solution in
      Answer (report, stdout, stderr, outcomes)
    with exn ->
      let msg = match exn with
        | Grading.User_code_error { Toploop_results.msg } ->
            "Error in your solution:\n" ^ msg
        | Grading.Internal_error (step, { Toploop_results.msg }) ->
            "Internal error " ^ step ^ "\n" ^ msg
        | Grading.Invalid_grader ->
            "Internal error:\nThe grader did not return a report."
        | exn ->
            "Unexpected error:\n" ^ Printexc.to_string exn in
      let report = Report.[ Message ([ Code msg ], Failure) ] in
      Answer (report, "", "" ,"") in
  let json = Browser_json.Json_encoding.construct from_worker_enc ans in
  Worker.post_message json