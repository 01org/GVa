/* Copyright (c) 2016 Intel Corporation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above
 * copyright notice, this list of conditions and the following
 * disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of
 * its contributors may be used to endorse or promote products
 * derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace GVa {
public class Config : Object {

public Display d;
public Va.ConfigID id;

public Config (Display display, Va.ConfigID config_id)
{
  d = display;
  id = config_id;
}

~Config ()
{
  Va.destroy_config (d.disp, id);
  id = Va.INVALID_ID;
}

public Va.ConfigAttrib[]
query_config_attributes (out Va.Profile profile, out Va.Entrypoint entrypoint)
{
  int num_attribs = Va.max_num_config_attributes (d.disp);
  var attribs = new Va.ConfigAttrib[num_attribs];
  Va.Profile p = Va.Profile.NONE;
  Va.Entrypoint e = Va.Entrypoint.VLD;

  var status = Va.query_config_attributes (d.disp, id, ref p, ref e,
      ref attribs[0], ref num_attribs);
  profile = p;
  entrypoint = e;

  if (status == Va.STATUS_SUCCESS)
    attribs.length = num_attribs;
  else
    attribs.length = 0;

  return attribs;
}

public Va.SurfaceAttrib[]
query_surface_attributes ()
{
  uint num_attribs = 0;
  var attribs = new Va.SurfaceAttrib[0];
  Va.SurfaceAttrib? nil = null;

  var status = Va.query_surface_attributes (d.disp, id, ref nil,
      ref num_attribs);
  if (status != Va.STATUS_ERROR_MAX_NUM_EXCEEDED)
    return attribs;
  
  attribs.length = (int)num_attribs;
  status = Va.query_surface_attributes (d.disp, id, ref attribs[0],
      ref num_attribs);
  if (status != Va.STATUS_SUCCESS)
    attribs.length = 0;
  else
    attribs.length = (int)num_attribs;

  return attribs;
}

public Context?
create_context (int picture_width, int picture_height, int flag,
    Surface[] targets)
{
  var target_ids = new Va.SurfaceID[targets.length];
  for (int i = 0; i < targets.length; i++)
    target_ids[i] = targets[i].id;

  Va.ContextID context = Va.INVALID_ID;
  var status = Va.create_context (d.disp, id, picture_width, picture_height,
      flag, ref target_ids[0], target_ids.length, ref context);

  if (status == Va.STATUS_SUCCESS)
    return new Context (d, context);
  else
    return null;
}

}
}
