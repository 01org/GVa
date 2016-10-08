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
public class Surface : Object {

public Display d;
public Va.SurfaceID id;

public Surface (Display display, Va.SurfaceID surface_id)
{
  d = display;
  id = surface_id;
}

~Surface ()
{
  Va.destroy_surfaces (d.disp, ref id, 1);
  id = Va.INVALID_ID;
}

public Va.Status
sync ()
{
  return Va.sync_surface (d.disp, id);
}

public bool
query_status (out Va.SurfaceStatus surface_status)
{
  Va.SurfaceStatus s = 0;

  var status = Va.query_surface_status (d.disp, id, ref s);
  surface_status = s;
  return status == Va.STATUS_SUCCESS;
}

public bool
get_image (int x, int y, uint width, uint height, Image image)
{
  return Va.get_image (d.disp, id, x, y, width, height, image.i.image_id)
      == Va.STATUS_SUCCESS;
}

public bool
put_image (Image image, Va.Rectangle src, Va.Rectangle dest)
{
  return Va.put_image (d.disp, id, image.i.image_id, src.x, src.y, src.width,
      src.height, dest.x, dest.y, dest.width, dest.height) == Va.STATUS_SUCCESS;
}

public Image?
derive_image ()
{
  Va.Image image = {0};

  var status = Va.derive_image (d.disp, id, ref image);

  if (status == Va.STATUS_SUCCESS)
    return new Image (d, image);
  else
    return null;
}

}
}
