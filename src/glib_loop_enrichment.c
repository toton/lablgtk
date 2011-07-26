/*
  In order to execute jobs queued by GtkThread.async, we ask glib to wait on a pipe.
  It will wake the main loop up and execute our dispatch function. It will do the awaiting job.
  The pipe acts as a semaphore initially set to 0.
*/
#include <stdio.h>
#include <unistd.h>

#include <caml/mlvalues.h>
#include <caml/signals.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/unixsupport.h>
#include <caml/fail.h>
#include <glib.h>

int semaphore_pipe_wr_fd = 0;
char onebyte;
GPollFD event_poll_rd_fd;
value *GtkThread_do_jobs = 0;

gboolean prepare(GSource *source, gint *timeout)
{
  *timeout = -1;
  return FALSE;
}

gboolean check(GSource *source)
{
  return event_poll_rd_fd.revents & G_IO_IN;
}

gboolean dispatch(GSource *source, GSourceFunc callback, gpointer user_data)
{
  ssize_t cread = read(event_poll_rd_fd.fd, &onebyte, 1);

  if ((cread < 0) || !GtkThread_do_jobs)
    {fprintf(stderr,"Error: "__FILE__":%i\n", __LINE__); return TRUE;}

  caml_leave_blocking_section();
  (void)caml_callback_exn(*GtkThread_do_jobs, Val_unit);
  caml_enter_blocking_section();
  return TRUE;
}

static GSourceFuncs event_funcs = {prepare, check, dispatch, NULL};

CAMLprim value enrich_glib_loop(value nothing)
{
  GtkThread_do_jobs = caml_named_value("GtkThread.safe_do_jobs");

  int fd[2];
  int result = pipe(fd);
  if (result == -1) caml_failwith(__FILE__":56");
  semaphore_pipe_wr_fd = fd[1];

  event_poll_rd_fd.events = G_IO_IN;
  event_poll_rd_fd.fd = fd[0];

  GSource *source = g_source_new(&event_funcs, sizeof (GSource));
  g_source_add_poll(source, &event_poll_rd_fd);
  g_source_set_can_recurse(source, FALSE);
  g_source_attach(source, NULL);

  return Val_unit;
}

CAMLprim value signal_queue_grown(value nothing)
{
  if (!semaphore_pipe_wr_fd) caml_failwith(__FILE__":71");
  ssize_t result = write(semaphore_pipe_wr_fd, &onebyte, 1);
  if (result == -1) caml_failwith(__FILE__":72");
  return Val_unit;
}
