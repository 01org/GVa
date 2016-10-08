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
public class Buffer : Object {

public Display d;
public Va.BufferID id;

public Buffer (Display display, Va.BufferID buffer_id)
{
  d = display;
  id = buffer_id;
}

~Buffer ()
{
  Va.destroy_buffer (d.disp, id);
  id = Va.INVALID_ID;
}

public bool
set_num_elements (uint num_elements)
{
  return Va.buffer_set_num_elements (d.disp, id, num_elements)
      == Va.STATUS_SUCCESS;
}

public void*
map ()
{
  void *dat = null;

  var status = Va.map_buffer (d.disp, id, ref dat);
  if (status == Va.STATUS_SUCCESS)
    return dat;
  else
    return null;
}

public bool
unmap ()
{
  return Va.unmap_buffer (d.disp, id) == Va.STATUS_SUCCESS;
}

}
}
