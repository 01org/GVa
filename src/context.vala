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
public class Context : Object {

public Display d;
public Va.ContextID id;

public Context (Display display, Va.ContextID context_id)
{
  d = display;
  id = context_id;
}

~Context ()
{
  Va.destroy_context (d.disp, id);
  id = Va.INVALID_ID;
}

public Buffer?
create_buffer (Va.BufferType type, uint size, uint num_elements,
    void *data=null)
{
  Va.BufferID buffer = Va.INVALID_ID;
  var status = Va.create_buffer (d.disp, id, type, size, num_elements, data,
      ref buffer);
  if (status == Va.STATUS_SUCCESS)
    return new Buffer (d, buffer);
  else
    return null;
}

public bool
begin_picture (Surface render_target)
{
  return Va.begin_picture (d.disp, id, render_target.id) == Va.STATUS_SUCCESS;
}

public bool
render_picture (Buffer[] buffers)
{
  var buffer_ids = new Va.BufferID[buffers.length];
  for (int i = 0; i < buffers.length; i++)
    buffer_ids[i] = buffers[i].id;

  return Va.render_picture (d.disp, id, ref buffer_ids[0], buffer_ids.length)
      == Va.STATUS_SUCCESS;
}

public bool
end_picture ()
{
  return Va.end_picture (d.disp, id) == Va.STATUS_SUCCESS;
}

}
}
