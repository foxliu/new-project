/*
 * Copyright 2014 <copyright holder> <email>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 */

#include "menu5_head.h"

/* 
 * forward definitions
 */
G_DEFINE_TYPE (menu5_head, menu5_head, G_TYPE_OBJECT);
/*
/* forward declarations of default virtual methods 
 */

static void
menu5_head_dispose (GObject *gobject)
{
  menu5_head *self = MENU5_HEAD (gobject);

  /* 
   * In dispose, you are supposed to free all types referenced from this
   * object which might themselves hold a reference to self. Generally,
   * the most simple solution is to unref all members on which you own a 
   * reference.
   */

  /* Chain up to the parent class */
  G_OBJECT_CLASS (menu5_head_parent_class)->dispose (gobject);
}

static void
menu5_head_finalize (GObject *gobject)
{
  menu5_head *self = MENU5_HEAD (gobject);

  /* Chain up to the parent class */
  G_OBJECT_CLASS (menu5_head_parent_class)->finalize (gobject);
}

static void
menu5_head_init (menu5_head *self)
{
  /* initialize all public and private members to reasonable default values. */

  /* Default implementations for virtual methods 
   * For pure-virtual functions, set these to NULL
   */
}
