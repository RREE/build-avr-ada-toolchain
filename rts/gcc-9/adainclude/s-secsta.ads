------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--               S Y S T E M . S E C O N D A R Y _ S T A C K                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--    Copyright (C) 1992-2013, 2016-2019, Free Software Foundation, Inc.    --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This version is a simplified edition of the original
--  System.Secondary_Stack from gcc-4.7 and gcc-9.2 for use in single
--  threaded AVR applications.

pragma Compiler_Unit_Warning;

with System.Parameters;
with System.Storage_Elements;

package System.Secondary_Stack is
   pragma Preelaborate;

   package SP renames System.Parameters;
   package SSE renames System.Storage_Elements;

   type SS_Stack (Size : SP.Size_Type) is private;
   type SS_Stack_Ptr is access all SS_Stack with Storage_Size => 0;

   procedure SS_Init
     (Stack : in out SS_Stack_Ptr;
      Size  : SP.Size_Type := SP.Unspecified_Size);
   --  Initialize the given secondary stack Stack.

   procedure SS_Allocate
     (Addr         : out System.Address;
      Storage_Size : SSE.Storage_Count);
   --  Allocate enough space for a 'Storage_Size' bytes object with
   --  maximum alignment. The address of the allocated space is
   --  returned in Addr.

   type Mark_Id is private;
   --  Type used to mark the stack for mark/release processing

   function SS_Mark return Mark_Id;
   --  Return the Mark corresponding to the current state of the stack

   procedure SS_Release (M : Mark_Id);
   --  Restore the state of the stack corresponding to the mark M.

   function SS_Get_Max return Long_Long_Integer;
   --  Return maximum used space in storage units for the current secondary
   --  stack.

private
   SS_Pool : Integer;
   --  Unused entity that is just present to ease the sharing of the
   --  pool mechanism for specific allocation/deallocation in the
   --  compiler (???)

   subtype SS_Ptr is SP.Size_Type;

   type Memory is array (SS_Ptr range <>) of SSE.Storage_Element
   with
     Alignment => Standard'Maximum_Alignment;
   --  The region of memory that holds the stack itself.

   --  This stack grows up.
   type SS_Stack (Size : SP.Size_Type) is record
      Top : SS_Ptr;
      Max : SS_Ptr;
      Internal_Chunk : Memory (1 .. Size);
   end record;

   type Mark_Id is new SS_Ptr;

      ------------------------------------
   -- Binder Allocated Stack Support --
   ------------------------------------

   --  When the No_Implicit_Heap_Allocations or No_Implicit_Task_Allocations
   --  restrictions are in effect the binder statically generates secondary
   --  stacks for tasks who are using default-sized secondary stack. Assignment
   --  of these stacks to tasks is handled by SS_Init. The following variables
   --  assist SS_Init and are defined here so the runtime does not depend on
   --  the binder.

   Binder_SS_Count : Natural;
   pragma Export (Ada, Binder_SS_Count, "__gnat_binder_ss_count");
   --  The number of default sized secondary stacks allocated by the binder

   Default_SS_Size : SP.Size_Type;
   pragma Export (Ada, Default_SS_Size, "__gnat_default_ss_size");
   --  The default size for secondary stacks. Defined here and not in init.c/
   --  System.Init because these locations are not present on ZFP or
   --  Ravenscar-SFP run-times.

   Default_Sized_SS_Pool : System.Address;
   pragma Export (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");
   --  Address to the secondary stack pool generated by the binder that
   --  contains default sized stacks.

   Num_Of_Assigned_Stacks : Natural := 0;
   --  The number of currently allocated secondary stacks

end System.Secondary_Stack;
