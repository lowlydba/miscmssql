------------------------------------------------
-- Itanium is not supported in this calculation!
------------------------------------------------
-- MemToApps and RoomForOS should be manually 
-- specified below.
------------------------------------------------

	-- Memory for applications in MB
	DECLARE @MemToApps int;
	SET @MemToApps= 2048;
	-- Memory allocated to the OS in MB
	DECLARE @RoomForOS int; 
	SET @RoomForOS = 2048;

	-- querying max worker threads
	DECLARE @WT int
	SET @WT = (SELECT [max_workers_count] FROM sys.dm_os_sys_info);
	-- querying physical memory
	DECLARE @PhysicalMemory int
	SET @PhysicalMemory = (SELECT [physical_memory_in_bytes] / 1048576 FROM sys.dm_os_sys_info);

	IF OBJECT_ID('tempdb..#memory') IS NOT NULL
		DROP TABLE #memory;


	CREATE TABLE #memory
		(
			[PhysicalMemory] int,
			[RoomForOS] int,
			[MemToApps] int,
			[WorkerThreadMemory] int,
			[CalculatedMaxServerMemoryMB] int,
			[ConfiguredMaxServerMemoryMB] int,
			[ActiveMaxServerMemoryMB] int
		);

	-- Memory allocated to other apps than SQL Server.
	-- Eg.: antivirus, backups software + 1024 MB for multi-page alocation, sqlxml, etc.
	IF EXISTS (SELECT 1 FROM sys.configurations WHERE NAME LIKE '%64%')
	BEGIN
		-- 64 bit platform:

		INSERT INTO #memory
		SELECT
			@PhysicalMemory AS [PhysicalMemory], 
			@RoomForOS AS [RoomForOS], 
			@MemToApps AS [MemToApps], 
			CAST((@WT * 2) AS int) AS [WorkerThreadMemory],
			CAST((@PhysicalMemory - @RoomForOS - @MemToApps - (@WT * 2)) AS int) AS [CalculatedMaxServerMemoryMB],
			CAST([value] AS int) AS [ConfiguredMaxServerMemoryMB],
			CAST([value_in_use] AS int) AS [ActiveMaxServerMemoryMB]
		FROM sys.configurations
		WHERE [name] = 'max server memory (MB)';

	END
	ELSE BEGIN
		-- 32 bit platform:

		INSERT INTO #memory
		SELECT
			@PhysicalMemory AS [PhysicalMemory], 
			@RoomForOS AS [RoomForOS], 
			@MemToApps AS [MemToApps], 
			CAST((@WT * 0.5) AS int) AS [WorkerThreadMemory],
			CAST((@PhysicalMemory - @RoomForOS - @MemToApps - (@WT * 0.5)) AS int) AS [CalculatedMaxServerMemoryMB],
			CAST([value] AS int) AS [ConfiguredMaxServerMemoryMB],
			CAST([value_in_use] AS int) AS [ActiveMaxServerMemoryMB]
		FROM sys.configurations
		WHERE [name] = 'max server memory (MB)';
		
	END

	-- Returning results:
	SELECT * FROM #memory