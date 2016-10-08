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
public class Display : Object {

public Va.Display disp;

public Display (Va.Display d)
{
  int ign1 = 0, ign2 = 0;
  var status = Va.STATUS_ERROR_UNKNOWN;

  if (Va.display_is_valid (d) != 0)
    status = Va.initialize (d, ref ign1, ref ign2);

  if (status == Va.STATUS_SUCCESS)
    disp = d;
  else
    disp = (Va.Display)null;
}

~Display ()
{
  if (Va.display_is_valid (disp) != 0)
    Va.terminate (disp);
  disp = (Va.Display)null;
}

public unowned string?
query_vendor_string ()
{
  return Va.query_vendor_string (disp);
}

public Va.Profile[]
query_config_profiles ()
{
  int num_profiles = Va.max_num_profiles (disp);
  var profiles = new Va.Profile[num_profiles];

  var status = Va.query_config_profiles (disp, ref profiles[0], ref num_profiles);
  if (status == Va.STATUS_SUCCESS)
    profiles.length = num_profiles;
  else
    profiles.length = 0;

  return profiles;
}

public Va.Entrypoint[]
query_config_entrypoints (Va.Profile profile)
{
  int num_entrypoints = Va.max_num_entrypoints (disp);
  var entrypoints = new Va.Entrypoint[num_entrypoints];

  var status = Va.query_config_entrypoints (disp, profile, ref entrypoints[0],
      ref num_entrypoints);
  if (status == Va.STATUS_SUCCESS)
    entrypoints.length = num_entrypoints;
  else
    entrypoints.length = 0;

  return entrypoints;
}

public Va.ImageFormat[]
query_image_formats ()
{
  int num_image_formats = Va.max_num_image_formats (disp);
  var image_formats = new Va.ImageFormat[num_image_formats];

  var status = Va.query_image_formats (disp, ref image_formats[0],
      ref num_image_formats);
  if (status == Va.STATUS_SUCCESS)
    image_formats.length = num_image_formats;
  else
    image_formats.length = 0;

  return image_formats;
}

public bool
get_config_attributes (Va.Profile profile, Va.Entrypoint entrypoint,
    ref Va.ConfigAttrib[] attribs)
{
  return Va.get_config_attributes (disp, profile, entrypoint, ref attribs[0],
      attribs.length) == Va.STATUS_SUCCESS;
}

public Config?
create_config (Va.Profile profile, Va.Entrypoint entrypoint,
    Va.ConfigAttrib[] attribs)
{
  Va.ConfigID config = Va.INVALID_ID;

  var status = Va.create_config (disp, profile, entrypoint, ref attribs[0],
      attribs.length, ref config);

  if (status == Va.STATUS_SUCCESS)
    return new Config (this, config);
  else
    return null;
}

public Surface?
create_surface (uint format, uint width, uint height, Va.SurfaceAttrib[] attrs)
{
  Va.SurfaceID surface = Va.INVALID_ID;

  var status = Va.create_surfaces (disp, format, width, height, ref surface, 1,
      ref attrs[0], attrs.length);

  if (status == Va.STATUS_SUCCESS)
    return new Surface (this, surface);
  else
    return null;
}

public Image?
create_image (Va.ImageFormat format, int width, int height)
{
  Va.Image image = {0};

  var status = Va.create_image (disp, ref format, width, height, ref image);

  if (status == Va.STATUS_SUCCESS)
    return new Image (this, image);
  else
    return null;
}

}
}
