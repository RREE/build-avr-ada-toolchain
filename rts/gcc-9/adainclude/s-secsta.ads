------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--               S Y S T E M . S E C O N D A R Y _ S T A C K                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 1992-2011, Free Software Foundation, Inc.         --
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
--  System.Secondary_Stack from gcc-4.7 for use in single threaded AVR
--  applications.

with System.Storage_Elements;

package System.Secondary_Stack is

   package SSE renames System.Storage_Elements;

   Default_Secondary_Stack_Size : constant := 512;
   --  Default size of a secondary stack

   procedure SS_Init
     (Stk  : System.Address;
      Size : Natural := Default_Secondary_Stack_Size);
   --  Initialize the secondary stack with a main stack of the given Size.

   procedure SS_Allocate
     (Address      : out System.Address;
      Storage_Size : SSE.Storage_Count);
   --  Allocate enough space for a 'Storage_Size' bytes object with Maximum
   --  alignment. The address of the allocated space is returned in 'Address'

   type Mark_Id is private;
   --  Type used to mark the stack for mark/release processing

   function SS_Mark return Mark_Id;
   --  Return the Mark corresponding to the current state of the stack

   procedure SS_Release (M : Mark_Id);
   --  Restore the state of the stack corresponding to the mark M. If an
   --  additional chunk have been allocated, it will never be freed during a

private

   SS_Pool : Integer;
   --  Unused entity that is just present to ease the sharing of the pool
   --  mechanism for specific allocation/deallocation in the compiler

   type Mark_Id is new SSE.Integer_Address;

end System.Secondary_Stack;
