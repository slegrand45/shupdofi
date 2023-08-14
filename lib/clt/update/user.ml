module Action = Shupdofi_clt_model.Action
module Action_other = Shupdofi_clt_action
module Api = Shupdofi_clt_api.Api
module Com = Shupdofi_com
module Model = Shupdofi_clt_model.Model
module Routing = Shupdofi_clt_routing

open Vdom

let update m a =
  match a with
  | Action_other.User.Do ->
    return m ~c:[Api.http_get ~url:(Routing.Api.(to_url User)) ~payload:"" (fun status json -> Action.User (Action_other.User.Done { status; json }))]
  | Action_other.User.Done { status; json } -> (
      match status with
      | 200 ->
        let m = { m with Model.user = Yojson.Safe.from_string json |> Com.User.t_of_yojson } in
        return m
      | _ ->
        return m
    )