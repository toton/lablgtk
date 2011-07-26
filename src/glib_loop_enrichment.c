/*
  In order to execute jobs queued by GtkThread.async, we ask glib to wait on a pipe.
  It will wake the main loop up and execute our dispatch function. It will do the awaiting job.
  The pipe acts as a semaphore initially set to 0.
*/
#include <stdio.h>
#include <unistd.h>
#include <poll.h>

#include <caml/mlvalues.h>
#include <caml/signals.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/unixsupport.h>
#include <caml/fail.h>
#include <glib.h>

#define error(msg) fprintf(stderr, "%s:%i %s\n", __FILE__, __LINE__, msg);
#define debug(msg) fprintf(stderr, "%s:%i %s\n", __FILE__, __LINE__, msg);
#define debugi(msg, vv) fprintf(stderr, "%s:%i %s=%i\n", __FILE__, __LINE__, (msg), (vv))

int semaphore_pipe_wr_fd = 0;
char onebyte;
GPollFD event_poll_rd_fd;
value *GtkThread_do_jobs = 0;

gboolean prepare(GSource *source, gint *timeout)
{
  struct pollfd pfd;
  pfd.fd = event_poll_rd_fd.fd;
  pfd.events = POLLIN;
  int poll_result = poll(&pfd, 1, 0);
  switch(poll_result)
  {
    case 0:
      *timeout = -1;
      return FALSE;
    case 1:
      return TRUE;
    default:
      error("poll");
  }
}

gboolean check(GSource *source)
{
//  debugi("GLE-check", (event_poll_rd_fd.revents & G_IO_IN));
  return event_poll_rd_fd.revents & G_IO_IN;
}

gboolean dispatch(GSource *source, GSourceFunc callback, gpointer user_data)
{
  debug("GLE-dispatch");
  ssize_t cread = read(event_poll_rd_fd.fd, &onebyte, 1);

  if ((cread < 0) || !GtkThread_do_jobs) {error(""); return TRUE;}

  //caml_leave_blocking_section();

  gdk_threads_enter();
  (void)caml_callback_exn(*GtkThread_do_jobs, Val_unit);
  gdk_threads_leave();

  //caml_enter_blocking_section();
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
  debug("Grown");
  if (!semaphore_pipe_wr_fd) caml_failwith(__FILE__":71");
  ssize_t result = write(semaphore_pipe_wr_fd, &onebyte, 1);
  if (result == -1) caml_failwith(__FILE__":72");
  debug("signal_queue_grown written");
  return Val_unit;
}
