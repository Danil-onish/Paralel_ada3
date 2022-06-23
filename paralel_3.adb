with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;
with Ada.Text_IO; use Ada.Text_IO;
with System;
with Ada.Numerics.Discrete_Random;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Paralel_3 is
   Access_Storage : Counting_Semaphore (1, Default_Ceiling);
   Full_Storage   : Counting_Semaphore (10, Default_Ceiling);
   Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

   
   
package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;
   
   Storage : List;
   item : integer :=1;
   
   function Random(left,right : integer) return Integer is
      subtype Random_Range is Integer range left .. right;
      package R is new
        Ada.Numerics.Discrete_Random (Random_Range);
      use R;
      G : Generator;
      X : Random_Range;
   begin
      Reset (G);
      X := Random (G);
      return X;
   end Random;
   
   
   task type producer is 
         entry start(Item_Numbers : in Integer);
      end producer;
           
      task body producer is
      Item_Numbers : Integer;
      Storage : List;
      begin
         accept start(Item_Numbers : in Integer) do
         producer.Item_Numbers := Item_Numbers;
         producer.Storage := Storage;
         end start;
         
         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            Access_Storage.Seize;

         Storage.Append ("item " & item'Img);       
         Put_Line ("Added item " & item'Img);
         
         item := item +1;

            Access_Storage.Release;
            Empty_Storage.Release;
            --delay 1.0;
         end loop;
      end producer;

      task type consumer is
         entry start(Item_Numbers : in Integer);
      end consumer;
      
      task body consumer is
      Item_Numbers : Integer; 
      Storage : List;
      begin
        accept start(Item_Numbers : in Integer) do
         consumer.Item_Numbers := Item_Numbers;
         consumer.Storage := Storage;   
         end start;

         for i in 1 .. Item_Numbers loop
         Empty_Storage.Seize; 
         Access_Storage.Seize;      

         Put_Line ("Took item " );
         Storage.Delete_First;
         
         Full_Storage.Release;
         Access_Storage.Release;
         
           

            --delay 1.0;
         end loop;
      end consumer;
   
   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer; Producers : in Integer) is

      producerss : array(1..Producers) of producer;
      consumerss : array(1..Producers) of consumer;
      
   begin
      Put_Line("Storage size: "& Integer'Image(Storage_Size));
      Put_Line("Number of items: "& Integer'Image(Item_Numbers));
      Put_Line("Producers: "& Integer'Image(Producers));
      Put_Line("Consumers: "& Integer'Image(Producers));
      New_Line;
      for i in 1..Producers loop
         producerss(i).start(Item_Numbers);
         consumerss(i).start(Item_Numbers);
      end loop;
      

       
   end Starter;

begin
   
   Starter (10, Random(2,5),Random(2,4));
end Paralel_3;
